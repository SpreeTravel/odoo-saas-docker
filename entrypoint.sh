#!/bin/bash

set -e

# Set odoo database host, port, user and password
: ${PGHOST:=${RDS_HOSTNAME:=${PGHOST:='localhost'}}}
: ${PGPORT:=${RDS_PORT:=${PGPORT:=5432}}}
: ${PGDB:=${RDS_DB_NAME:=${PGDB:='postgres'}}}
: ${PGUSER:=${RDS_USERNAME:=${PGUSER:='odoo'}}}
: ${PGPASSWORD:=${RDS_PASSWORD:=${PGPASSWORD}}}
export PGHOST PGPORT PGUSER PGPASSWORD PGDB

echo "PostgreSQL variables exported, attempting to create initial databases"

python /etc/odoo/makedb.py

CUSTOM_MODULES_PATH=/mnt/odoo-custom-addons

if [ ! -f /mnt/odoo-saas-tools/firstrun.lock ]
then
	echo "Cloning custom addons repositories into $CUSTOM_MODULES_PATH"
	CUSTOM_MODULES_LIST=""
	count=0
	for x in $CUSTOM_MODULES; do
		((count++))
		REPO_PATH=$CUSTOM_MODULES_PATH/custom_$count
		mkdir -p $REPO_PATH
		git clone $x $REPO_PATH
		CUSTOM_MODULES_LIST="$CUSTOM_MODULES_LIST,$REPO_PATH"
	done
	sed -i "s/,$CUSTOM_MODULES_PATH/$CUSTOM_MODULES_LIST/g" $OPENERP_SERVER

	echo "Initial databases succesfully created, performing initial setup"
	# Generate UUID for the server database
	uuid=$(cat /proc/sys/kernel/random/uuid)
	# Update docker addons for odoo
	sed -i "s/odoo.local/$MAIN_DOMAIN/g" /mnt/odoo-saas-tools/saas_server/data/auth_oauth_data.xml
	sed -i "s/odoo.local/$SERVER_SUBDOMAIN/g" /mnt/odoo-saas-tools/saas_server/data/ir_config_parameter.xml
	sed -i "s/server_subdomain/$SERVER_SUBDOMAIN/g" /mnt/odoo-saas-docker/saas_portal_docker/data/server.xml
	sed -i "s/server_client_id/$uuid/g" /mnt/odoo-saas-docker/saas_portal_docker/data/server.xml
	sed -i "s/server_client_id/$uuid/g" /mnt/odoo-saas-docker/saas_server_docker/data/provider.xml

	# Install docker modules on portal and server database
	echo "Installing docker modules on server database"
	openerp-server -c $OPENERP_SERVER -d $SERVER_SUBDOMAIN -i saas_server_docker --without-demo=all --stop-after-init
	echo "Installing docker modules on portal database"
	openerp-server -c $OPENERP_SERVER -d $MAIN_DOMAIN -i saas_portal_docker --without-demo=all --stop-after-init

	echo "Done" > /mnt/odoo-saas-tools/firstrun.lock
else
	echo "Databases already existant... updating Git repositories"
	cd /mnt/odoo-saas-tools && git pull origin upstream

	for x in `ls -d $CUSTOM_MODULES_PATH/*/`; do
		cd $x && git pull
	done
fi

echo "Running openerp-server"
case "$1" in
	--)
		shift
		exec openerp-server "$@"
		;;
	-*)
		exec openerp-server "$@"
		;;
	*)
		exec "$@"
esac


exit 1

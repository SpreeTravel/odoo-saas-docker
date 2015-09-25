#!/bin/bash

set -e

# Set odoo database host, port, user and password
: ${PGHOST:=${RDS_HOSTNAME:=${PGHOST:=${DB_PORT_5432_TCP_ADDR:='localhost'}}}}
: ${PGPORT:=${RDS_PORT:=${PGPORT:=${DB_PORT_5432_TCP_PORT:=5432}}}}
: ${PGUSER:=${RDS_USERNAME:=${PGUSER:=${DB_ENV_POSTGRES_USER:='postgres'}}}}
: ${PGPASSWORD:=${RDS_PASSWORD:=${PGPASSWORD:=$DB_ENV_POSTGRES_PASSWORD}}}
: ${PGDB:=${RDS_DB_NAME:=${PGDB:='postgres'}}}
export PGHOST PGPORT PGUSER PGPASSWORD PGDB

echo "PostgreSQL variables exported, attempting to create initial databases"

python /etc/odoo/makedb.py

CUSTOM_MODULES_PATH=/mnt/odoo-custom-addons
CUSTOM_REPOS_PATH=/mnt/odoo-custom-repos

if [ ! -f /mnt/odoo-saas-tools/firstrun.lock ]
then
	echo "Cloning custom addons repositories into $CUSTOM_MODULES_PATH"
	count=0
	for x in $CUSTOM_REPOS
	do
		count=$((count+1))
		REPO_PATH=$CUSTOM_REPOS_PATH/repo_$count
		echo "Creating directory $REPO_PATH"
		mkdir -p $REPO_PATH
		echo "Cloning $x into $REPO_PATH"
		git clone $x $REPO_PATH
		for addon in `ls -d $REPO_PATH/*/`; do
			echo "Copying $addon to $CUSTOM_MODULES_PATH"
			cp -R $addon $CUSTOM_MODULES_PATH/
		done
	done

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
	openerp-server -c /etc/odoo/openerp-server.conf -d $SERVER_SUBDOMAIN -i saas_server_docker --without-demo=all --stop-after-init
	echo "Installing docker modules on portal database"
	openerp-server -c /etc/odoo/openerp-server.conf -d $MAIN_DOMAIN -i saas_portal_docker --without-demo=all --stop-after-init

	echo "Done" > /mnt/odoo-saas-tools/firstrun.lock
else
	echo "Databases already existant... updating Git repositories"
	cd /mnt/odoo-saas-tools && git pull origin upstream

	rm -rf $CUSTOM_MODULES_PATH/*

	for x in `ls -d $CUSTOM_REPOS_PATH/*/`; do
		cd $x && git pull
		for addon in `ls -d $x/*/`; do
			cp -R $addon $CUSTOM_MODULES_PATH/
		done
	done

	# Update docker modules on portal and server database in order to force an update_modules_list
	echo "Upgrading docker modules on server database"
	openerp-server -c /etc/odoo/openerp-server.conf -d $SERVER_SUBDOMAIN -u saas_server_docker --stop-after-init
	echo "Upgrading docker modules on portal database"
	openerp-server -c /etc/odoo/openerp-server.conf -d $MAIN_DOMAIN -u saas_portal_docker --stop-after-init
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

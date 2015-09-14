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

if [ ! -f /mnt/odoo-saas-tools/firstrun.lock ]
then
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
	echo "Databases already existant... continuing"
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

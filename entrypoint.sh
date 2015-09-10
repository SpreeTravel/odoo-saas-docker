#!/bin/bash

set -e

# Set odoo database host, port, user and password
: ${PGHOST:=${RDS_HOSTNAME:=${PGHOST:='localhost'}}}
: ${PGPORT:=${RDS_PORT:=${PGPORT:=5432}}}
: ${PGUSER:=${RDS_USERNAME:=${PGUSER:='odoo'}}}
: ${PGPASSWORD:=${RDS_PASSWORD:=${PGPASSWORD}}}
export PGHOST PGPORT PGUSER PGPASSWORD

# Generate UUID for the server database
uuid=$(cat /proc/sys/kernel/random/uuid)
# Update docker addons for odoo
sed -i "s/odoo.local/$SERVER_SUBDOMAIN:8069/g" /mnt/odoo-saas-tools/saas_server/data/ir_config_parameter.xml
sed -i "s/server_subdomain/$SERVER_SUBDOMAIN/g" /mnt/odoo-saas-tools/saas_portal_docker/data/server.xml
sed -i "s/server_client_id/$uuid/g" /mnt/odoo-saas-tools/saas_portal_docker/data/server.xml
sed -i "s/server_client_id/$uuid/g" /mnt/odoo-saas-tools/saas_server_docker/data/provider.xml

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

python /etc/odoo/makedb.py

exit 1

#!/bin/bash

set -e

# set odoo database host, port, user and password
: ${PGHOST:=${RDS_HOSTNAME:=${PGHOST:='localhost'}}}
: ${PGPORT:=${RDS_PORT:=${PGPORT:=5432}}}
: ${PGUSER:=${RDS_USERNAME:=${PGUSER:='postgres'}}}
: ${PGPASSWORD:=${RDS_PASSWORD:=$PGPASSWORD}}
export PGHOST PGPORT PGUSER PGPASSWORD

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

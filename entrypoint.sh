#!/bin/bash

set -e

# set odoo database host, port, user and password
: ${PGHOST:=${PGHOST:='localhost'}}
: ${PGPORT:=${PGPORT:=5432}}
: ${PGUSER:=${PGUSER:='postgres'}}
: ${PGPASSWORD:=$PGPASSWORD}
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

import os
import sys

from psycopg2 import connect
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

st = 0
try:
    print "\tAttempting to connect to MAIN_DOMAIN...",
    conn = connect(
        dbname=os.environ['MAIN_DOMAIN'],
        user=os.environ['PGUSER'],
        host=os.environ['PGHOST'],
        port=os.environ['PGPORT'],
        password=os.environ['PGPASSWORD'],
    )
    print "connected! No need to continue"
except:
    print "failed!"
    print "\tAttempting to connect to PGDB...",
    conn = connect(
        dbname=os.environ['PGDB'],
        user=os.environ['PGUSER'],
        host=os.environ['PGHOST'],
        port=os.environ['PGPORT'],
        password=os.environ['PGPASSWORD'],
    )
    print "connected!"
    print "\tCreating MAIN_DOMAIN and SERVER_SUBDOMAIN...",

    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cr = conn.cursor()
    cr.execute('CREATE DATABASE "{}" OWNER {};'.format(os.environ['MAIN_DOMAIN'], os.environ['PGUSER']))
    cr.execute('CREATE DATABASE "{}" OWNER {};'.format(os.environ['SERVER_SUBDOMAIN'], os.environ['PGUSER']))
    cr.close()
    conn.close()
    st = 1
    print "done!"


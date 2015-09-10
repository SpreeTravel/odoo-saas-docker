import os

from psycopg2 import connect
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

conn = connect(
    dbname=os.environ['PGDB'],
    user=os.environ['PGUSER'],
    host=os.environ['PGHOST'],
    port=os.environ['PGPORT'],
    password=os.environ['PGPASSWORD'],
)

conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
cr = conn.cursor()
cr.execute('CREATE DATABASE "{}" OWNER {};'.format(os.environ['MAIN_DOMAIN'], os.environ['PGUSER']))
cr.execute('CREATE DATABASE "{}" OWNER {};'.format(os.environ['SERVER_SUBDOMAIN'], os.environ['PGUSER']))
cr.close()
conn.close()

# Portal Database
#portaldb = os.environ['MAIN_DOMAIN']
#client.create_database('admin', portaldb)
#client.login('admin', 'admin', portaldb)
#client.install('saas_portal_docker')

# Server Database
#serverdb = os.environ['SERVER_SUBDOMAIN']
#client.create_database('admin', serverdb)
#client.login('admin', 'admin', serverdb)
#client.install('saas_server_docker')

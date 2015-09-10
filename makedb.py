import os
import erppeek

client = erppeek.Client('http://localhost:8069')

# Portal Database
portaldb = os.environ['MAIN_DOMAIN']
client.create_database('admin', portaldb)
client.login('admin', 'admin', portaldb)
client.install('saas_portal_docker')

# Server Database
serverdb = os.environ['SERVER_SUBDOMAIN']
client.create_database('admin', serverdb)
client.login('admin', 'admin', serverdb)
client.install('saas_server_docker')
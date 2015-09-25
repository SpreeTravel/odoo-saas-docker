# Odoo for SaaS solutions

This repository contains an image of Odoo (former OpenERP) to provide SaaS
solutions.

## What is Odoo

Odoo, formerly known as OpenERP, is a suite of open-source business apps written
in Python and released under the AGPL license. This suite of applications covers
all business needs, from Website/Ecommerce down to manufacturing, inventory and
accounting, all seamlessly integrated. It is the first time ever a software
editor managed to reach such a functional coverage. Odoo is the most installed
business software in the world. Odoo is used by 2.000.000 users worldwide
ranging from very small companies (1 user) to very large ones (300 000 users).

## Database setup

You have a variety of options to set your PostgreSQL database connection.

* Amazon EBS with Amazon RDS instance (simply instruct the Environment Wizard to
  launch a new RDS instance with the Environment).
* Custom PostgreSQL server installations via environment variables (`PGHOST`,
  `PGPORT`, `PGUSER`, `PGPASSWORD`).
* Traditional linking to PostgreSQL container.

If none of the above is provided it defaults to a localhost
PostgreSQL installation.

## SaaS setup

There are two mandatory environment variables you need to setup

### Mandatory

* `MAIN_DOMAIN`: identifies your central system, what we call the 'Portal'
  (e.g: `example.com`)
* `SERVER_SUBDOMAIN`: identifies the tenants server (only one at the moment,
  many on future updates) (e.g: `server.example.com`)

### Optional

* `CUSTOM_REPOS`: a comma sepparated list of git repositories. Be aware that the
  repositories must be reachable simply by it's URL (e.g:
  `https://github.com/myself/myrepo.git,https://github.com/someoneelse/hisrepo.git`
  )


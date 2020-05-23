## Postgres testing in fresh docker
I have been using a [postgresql test docker
image](https://wiki.postgresql.org/wiki/PostgreSQLTestDockerImage).

Start the image/server (might have to ctrl-c exit after starting server):
```bash
docker run -it --rm \
    -v $(pwd):/home/lamda-api \
    jberkus/postgres95-test

su - postgres
pg_ctl start >/dev/null
```

Open postgres shell:
```bash
psql -U postgres
```

In postgres:
```postgres
create database test;

\c test;

create schema schema_private;

set search_path to schema_private;

create extension if not exists "uuid-ossp";
```

Load file into database. You can repeatedly call this step after
updating the database SQL.
```bash
psql -U postgres -d test -a -f /home/lambda-api/db/schema_private.sql
```

You can generate the production sql file and repeat everything
replacing `schema_private` with `schema` in the above step.
```bash
./scripts/generate_db_sql.sh
psql -U postgres -d test -a -f /home/lambda-api/db/schema.sql
```

## Postgres testing live

The private schema should be updated and tested before shipping the
produciton version.

* Run the update script on the production db (will need password):
```bash
psql -host [AWS_HOST_PATH] -U postgres -d test -f db/schema_private.sql
```

* Test the lambda functions on the private database (TODO):
```bash
python3 -m unittest discover python/test
```

* Visually inspect the private database updates with a GUI (i.e. pgAdmin)

* Generate the production sql and update the prod database
```bash
./scripts/generate_db_sql.sh
psql test \
    --host terraform-20200504003723088500000001.ca4wx7axbfjm.us-east-1.rds.amazonaws.com \
    --username postgres \
    -a \
    -f db/schema.sql
```

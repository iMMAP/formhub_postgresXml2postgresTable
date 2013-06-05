formhub_postgresXml2postgresTable
=================================

Translates formhub XML stored in the formhub postgresql database dynamically to database tables

When formhub saves data to the database it is stored in xml format in a table field.  
This tool will allow users to create a trigger on this table so that this data can be automatiacally
translated into a independent tables for each form enabling relational and spatial analysis to be 
performed on the data using the postgresql (and postgis) engine.

install support:

    sudo apt-get install -y libpq-dev postgresql-9.1-dbg \
    postgresql-client-9.1 postgresql-server-dev-9.1 postgresql-doc-9.1 \
    postgresql-contrib-9.1 postgresql-plperl-9.1 postgresql-plpython-9.1 \
    postgresql-plpython3-9.1 postgresql-pltcl-9.1
    sudo apt-get install -y postgresql-plpython-9.1 postgresql-plpython3-9.1
  
on the formhub database in postgresql:
    
    CREATE EXTENSION plpythonu;
    CREATE EXTENSION plpython3u;

from postgres execute:
    1) create_trigger.sql
    2) add_trigger_to_table.sql

assumptions:
    schema called immap is available

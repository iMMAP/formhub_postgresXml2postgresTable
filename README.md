formhub_postgresXml2postgresTable
=================================

Translates formhub XML stored in the formhub postgresql database dynamically to database tables

When formhub saves data to the database it is stored in xml format in a table field.  
This tool will allow users to create a trigger on this table so that this data can be automatiacally
translated into a independent tables for each form enabling relational and spatial analysis to be 
performed on the data using the postgresql (and postgis) engine.

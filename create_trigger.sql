-- Function: immap_odk_logger_instance_to_table()

-- DROP FUNCTION immap_odk_logger_instance_to_table();

CREATE OR REPLACE FUNCTION immap_odk_logger_instance_to_table()
  RETURNS trigger AS
$BODY$
   from plpy import spiexceptions
   from xml.etree import ElementTree as ET

   schema_prefix = "immap."
   psql_create_table = 'CREATE TABLE IF NOT EXISTS ' + schema_prefix + '{0}({1});'
   psqlinsert = 'INSERT INTO ' + schema_prefix + '{0} ({1}) VALUES({2})'
   psqlupdate = 'UPDATE ' + schema_prefix + '{0} SET {1} WHERE uuid=\'{2}\''
   if TD['event'] == 'INSERT':
     sql_command = psqlinsert
   elif TD['event'] == 'UPDATE':
     sql_command = psqlupdate
     
   exception_set = ['formhub','meta','instanceID','deprecatedID']
   xmlstr = TD['new']['xml']
   if xmlstr == '':
     return
   tree = ET.fromstring(xmlstr)
   cnt = 0
   table_name = ''
   columns = ''
   extra = ''
   comma = ''
   comma_create_table = ''
   columns_str = ''
   parameters_str = ''
   parameters_type_list = []
   parameters_create_table_type_list = []
   parameters_list = []
   parameters_create_table = []
   uuid_str = TD["new"]["uuid"]
   event = TD["event"]
   if event == 'UPDATE' and uuid_str == '':
     return
   for node in tree.iter():
     data_type = 'character varying(255)'
     extra= ''
     if table_name == '':
       table_name = node.tag
       rs = plpy.execute("SELECT exists(SELECT table_catalog from information_schema.tables where table_schema = '" + schema_prefix + "' and table_name='{0}') AS is_exists".format(table_name))    
       if not rs[0]['is_exists']:
         event = 'INSERT'
         sql_command = psqlinsert
       if event == 'UPDATE':
         rs2 = plpy.execute("SELECT exists(SELECT uuid FROM " + schema_prefix + "{0} WHERE uuid ='{1}') as is_exists".format(table_name,uuid_str))
         if not rs2[0]['is_exists']:
           event = 'INSERT'
           sql_command = psqlinsert 
     else:
       if node.tag == 'uuid':
         extra = 'NOT NULL'
       if node.tag == 'gps':
         words = node.text.split()
         if len(words) >= 2:
           node.text = words[0] + ' ' + words[1]
         #node.text = node.text.replace(' 0 0','')  
       if not node.tag in exception_set:
         columns += '{0}{1} {2} {3} \n'.format(comma_create_table,node.tag,data_type,extra)
         comma_create_table = ','
         parameters_create_table.append(node.tag)
         
         if node.tag == 'uuid' and event == 'INSERT':
           parameters_list.append(uuid_str)
           parameters_type_list.append('text') 
         elif node.tag != 'uuid':
           parameters_list.append(node.text)
           parameters_type_list.append('text')
           
         parameters_create_table_type_list.append('text')
         if event == 'INSERT':
           columns_str += '{0}{1}'.format(comma,node.tag)
           cnt = cnt + 1 
           parameters_str += '{0}${1}'.format(comma,cnt)  
           comma = ','
         elif event == 'UPDATE':
           if node.tag != 'uuid':
             cnt = cnt + 1
             columns_str += '{0}{1}=${2}'.format(comma,node.tag,cnt)   
             comma = ','  
   if not rs[0]['is_exists']:
     plan= plpy.prepare(psql_create_table.format(table_name,columns), parameters_create_table_type_list)
     plpy.execute(plan, parameters_create_table)
   
   if event == 'INSERT':
     plan= plpy.prepare(sql_command.format(table_name,columns_str,parameters_str), parameters_type_list)
     plpy.execute(plan, parameters_list)
   elif event == 'UPDATE':
     plan= plpy.prepare(sql_command.format(table_name,columns_str,uuid_str), parameters_type_list)
     plpy.execute(plan, parameters_list)
 $BODY$
  LANGUAGE plpython3u VOLATILE
  COST 100;
ALTER FUNCTION immap_odk_logger_instance_to_table()
  OWNER TO postgres;
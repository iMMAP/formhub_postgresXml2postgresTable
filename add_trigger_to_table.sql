CREATE TRIGGER odk_logger_trigger_totable 
AFTER INSERT OR UPDATE OR DELETE ON odk_logger_instance
 
FOR EACH ROW EXECUTE PROCEDURE immap_odk_logger_instance_to_table(); 
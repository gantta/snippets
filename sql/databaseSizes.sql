select 
	DB_NAME(database_id) as DatabaseName
	,Name as Logical_Name
	,Physical_Name,
	(size*8)/1024 SizeMB
from sys.master_files
where DB_NAME(database_id) like '%_eThorityReporting'
  -- Ignore known system databases
  and DB_NAME(database_id) not like 'TEMPLATEv60Elements_%'
  and DB_NAME(database_id) not like 'WFA_Licensing_INT_%'
  and DB_NAME(database_id) not like 'WFA_Licensing_EXT_%'
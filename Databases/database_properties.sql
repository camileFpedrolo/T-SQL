-- bancos com recovery model full 
with CTE_TamanhoDB
as
(SELECT database_id,
[Database Name] = DB_NAME(database_id),
[Type] = CASE WHEN Type_Desc = 'ROWS' THEN 'Data File(s)'
WHEN Type_Desc = 'LOG' THEN 'Log File(s)'
ELSE Type_Desc END,
[Size in MB] = CAST( ((SUM(Size)* 8.0) / 1024.0) AS DECIMAL(18,2) ),
name as [LogicalName], physical_name as [Path]
FROM
sys.master_files
GROUP BY DB_NAME(database_id), Type_Desc, database_id,name,physical_name
/*GROUPING SETS
(
(DB_NAME(database_id), Type_Desc, database_id),
(DB_NAME(database_id))
)*/
)
select a.*, b.state_desc, 
	case
		when b.compatibility_level = 160 then 'SQL Server 2022'
		when b.compatibility_level = 150 then 'SQL Server 2019'
		when b.compatibility_level = 140 then 'SQL Server 2017'
		when b.compatibility_level = 130 then 'SQL Server 2016'
		when b.compatibility_level = 120 then 'SQL Server 2014'
		when b.compatibility_level = 110 then 'SQL Server 2012'
		when b.compatibility_level = 100 then 'SQL Server 2008/2008R2'
		when b.compatibility_level = 90 then 'SQL Server 2005'
		when b.compatibility_level = 80 then 'SQL Server 2000'
		else 'SQL Server'
	end  as CompatLevel,
 
b.recovery_model_desc as RecoveryModel,
	case b.is_read_committed_snapshot_on
		when 0 then 'Não'
		else 'Sim'
	end as [Read_Committed],
	case b.snapshot_isolation_state 
		when 0 then 'Não'
		else 'Sim'
	end as [Snapshot_Isolation],
	case b.is_auto_close_on
		when 0 then 'Não'
		else 'Sim'
	end as [Auto_Close],
	case b.is_auto_shrink_on
		when 0 then 'Não'
		else 'Sim'
	end as [Auto_Shrink],
	b.page_verify_option_desc
from 
	CTE_TamanhoDB a
	inner join sys.databases b on a.database_id = b.database_id
order by b.state_desc

-- return database size 

 SELECT d.NAME
    ,ROUND(SUM(CAST(mf.size AS bigint)) * 8 / 1024, 0) Size_MBs
    ,(SUM(CAST(mf.size AS bigint)) * 8 / 1024) / 1024 AS Size_GBs
FROM sys.master_files mf
INNER JOIN sys.databases d ON d.database_id = mf.database_id
WHERE d.database_id > 4 -- Skip system databases
GROUP BY d.NAME
ORDER BY d.NAME

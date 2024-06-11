EXEC sp_whoisactive 
@filter='session_number',@filter_type='session'
--Valid filter types are: session, program, database, login, host
 
 
EXEC sp_WhoIsActive
    @find_block_leaders = 1,
    @sort_order = '[blocked_session_count] DESC'
 
    
EXEC sp_whoisactive 
@delta_interval = 1,@sort_order = '[CPU_delta] DESC'
 
 
--https://www.sqlshack.com/monitoring-activities-using-sp_whoisactive-in-sql-server/

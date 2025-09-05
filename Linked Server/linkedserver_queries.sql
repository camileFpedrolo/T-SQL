SELECT
s.session_id,
s.login_name,
s.host_name,
r.status AS request_status,
r.command,
r.start_time,
r.cpu_time,
r.total_elapsed_time,
r.sql_handle,
r.plan_handle,
r.database_id,
r.remote_server_name,
r.remote_database_name,
r.database_id AS local_database_id
FROM
sys.dm_exec_sessions s
JOIN
sys.dm_exec_requests r ON s.session_id = r.session_id
WHERE
r.remote_server_name IS NOT NULL  -- Filtro para capturar apenas as consultas via Linked Server
AND r.command IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE')  -- Filtra os tipos de comando mais comuns
ORDER BY
r.start_time DESC;

---------------------------------------------------------------------------------------------------------

SELECT
s.session_id,
s.login_name,
s.host_name,
r.status AS request_status,
r.command,
r.start_time,
r.cpu_time,
r.total_elapsed_time,
r.sql_handle,
r.plan_handle,
t.text AS sql_text,
r.remote_server_name
FROM
sys.dm_exec_sessions s
JOIN
sys.dm_exec_requests r ON s.session_id = r.session_id
CROSS APPLY
sys.dm_exec_sql_text(r.sql_handle) t
WHERE
r.[RS-VMSQL05] IS NOT NULL  -- Filtra apenas as consultas via Linked Server
ORDER BY
r.start_time DESC;

--CONFERIR PROCESSOS EM EXECUÇÃO/PARADOS
select prc.spid, prc.blocked, prc.waittime, prc.cpu, prc.login_time, prc.last_batch, prc.status,
prc.cmd, prc.nt_domain, prc.nt_username, prc.loginame , text, lastwaittype
 from sys.sysprocesses prc
outer apply sys.dm_exec_sql_text(prc.sql_handle)
where prc.loginame <> ''   and prc.spid > 50 --and status <> 'sleeping'
order by blocked desc, nt_username desc
 
--Processos em execução
select prc.spid, prc.blocked, prc.waittime, prc.cpu, prc.login_time, prc.last_batch, prc.status,prc.cmd, prc.nt_domain, 
prc.nt_username, prc.loginame , text, lastwaittype, hostname, program_name 
from sys.sysprocesses prc outer apply sys.dm_exec_sql_text(prc.sql_handle)
where prc.loginame <> '' and prc.spid > 50 and status <> 'sleeping'order by blocked desc, nt_username desc
has context menu

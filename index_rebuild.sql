--EM CLIENTES QUE NÃO TEM CONTRATO, UMA SUGESTÃO E FAZER SOMENTE O REBUILD, TIRANDO TUDO QUE FAZER REORGANIZE E FAZER EM TODAS AS TABELAS E EM TODOS OS POSSÍVEIS ÍNDICES COM A SEGUINTE QUERY:
 
drop table #_CheckList_Fragmentacao_Indice;
 
create table #_CheckList_Fragmentacao_Indice(
    [cdhistoricofragmentacaoindice] [int] IDENTITY(1,1) NOT NULL,
    [dtreferencia] [datetime] NULL,
    [nmservidor] [nvarchar](50) NULL,
    [nmdatabase] [nvarchar](50) NULL,
    [nmschema] [nvarchar](200) NULL,
    [nmtabela] [nvarchar](200) NULL,
    [nmindice] [nvarchar](200) NULL,
    [nrfragmentacaopercentual] [float] NULL,
    [nrpagecount] [bigint] NULL,
    [nrfillfactor] [int] NULL
) ON [PRIMARY]
 
truncate table #_CheckList_Fragmentacao_Indice
go
 
with x
as (
select
getdate() data, @@SERVERNAME server, db_name(db_ID()) banco, s.name sX,
OBJECT_NAME(b.object_id) tabela, b.name Indice,
avg_fragmentation_in_percent MedPer , page_count PgNr, fill_factor ff
from sys.dm_db_index_physical_stats( db_ID(), null, null, null,null) a
inner join sys.indexes b
on a.object_id = b.object_id and a.index_id = b.index_id
inner join sys.tables t
on t.object_id = b.object_id
inner join sys.schemas s
on t.schema_id = s.schema_id
--where avg_fragmentation_in_percent > 5  and page_count > 1000
--    and b.name like '[I-R]%'
)
insert into #_CheckList_Fragmentacao_Indice(
dtreferencia, nmservidor, nmdatabase, nmschema, nmtabela, nmindice, nrfragmentacaopercentual,nrpagecount, nrfillfactor)
select * from x
 
SET NOCOUNT ON;
 
if (object_id('tempdb.dbo.#tbRebuild') is not null) drop table #tbRebuild
--if (object_id('tempdb.dbo.#tbReorganize') is not null) drop table #tbReorganize
 
 
Declare @tSQL varchar(Max)
DECLARE @DtReferencia datetime
 
create table #tbRebuild (NrLinha bigint identity(1,1), reindex varchar(max))
--create table #tbReorganize (NrLinha bigint identity(1,1), reindex varchar(max))
 
insert into #tbRebuild ( reindex)
select
'alter index [' + nmindice + '] on [' + nmdatabase + '].[' + nmschema + '].['+ nmtabela + '] rebuild partition = all WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = Off,  ONLINE = off, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)'
    from #_CheckList_Fragmentacao_Indice
    where
    nmindice is not null
    --and nrfragmentacaopercentual > 30
    and nmtabela not like '%tmp%'
    --and nrpagecount > 1000
 
--insert into #tbReorganize ( reindex)
--select
--'alter index [' + nmindice + '] on [' + nmdatabase + '].[' + nmschema + '].['+ nmtabela + '] reorganize with (lob_compaction = on)'
--    from #_CheckList_Fragmentacao_Indice
--    where
--    nmindice is not null
--    and nrfragmentacaopercentual <= 30
--    --and nrpagecount > 100
 
Declare @Contador int =1
Declare @Max int
set @Max = (select count(1) from #tbRebuild)
 
----REorganize
 
--While @Contador <= @Max
--begin
--    set @tSQL = (select reindex from #tbRebuild where NrLinha = @Contador )
--    print ('  ' + @tSQL)
--        PRINT ('PRINT '' + CAST(@Contador AS VARCHAR(10)) + '' DE ' + CAST(@Max AS VARCHAR(10)))
--    print ('go')
--    set @Contador = @Contador + 1
--end
 
set @Max = (select count(1) from #tbRebuild)
 
While @Contador <= @Max
begin
    set @tSQL = (select reindex from #tbRebuild where NrLinha = @Contador )
 
    print ('  ' + @tSQL)
    PRINT ('PRINT '''  + CAST(@Contador AS VARCHAR(10)) + ' DE ''  + ''' + CAST(@Max AS VARCHAR(10)) + '''')
    print ('go')
    set @Contador = @Contador + 1
end
 
--set @Max = (select count(1) from #tbReorganize)
--While @Contador <= @Max
--begin
--    set @tSQL = (select reindex from #tbReorganize where NrLinha = @Contador )
 
--    print ('  ' + @tSQL)
--    PRINT ('PRINT '''  + CAST(@Contador AS VARCHAR(10)) + ' DE ''  + ''' + CAST(@Max AS VARCHAR(10)) + '''')
--    print ('go')
 
--    set @Contador = @Contador + 1
--end

/*
Quando for um cliente não realizada update de estatísticas frequentemente, retirar a cláusula WHERE
*/
 
WITH STATS  (ID, Tabela, StatsName, ultAtl, modific, dias, comando)
 
as
 
(
 
SELECT DISTINCT
 
       TB.object_id
 
       ,TB.name
 
       ,ST.name
 
       ,stats.last_updated
 
       ,stats.modification_counter
 
       ,(DATEDIFF(d,stats.last_updated ,getdate()) ) AS 'DiasDesatualizados'
 
       ,'UPDATE STATISTICS [' + sc.name + '].['+TB.name+'] ['+ST.name+'] WITH FULLSCAN' as 'command'
 
  FROM sys.tables TB
 
  inner join sys.schemas sc on
 
  sc.schema_id = TB.schema_id
 
 INNER JOIN sys.stats ST ON TB.object_id = ST.object_id
 
 INNER JOIN sys.indexes IX ON TB.object_id = IX.object_id
 
 CROSS APPLY sys.dm_db_stats_properties(TB.object_id, ST.stats_id) as stats
 
 where (DATEDIFF(d,stats.last_updated ,getdate()) ) > 0
 
    and stats.modification_counter > 0
 
ORDER BY TB.name, ST.name
 
)
 
select * from STATS order by comando--- TAMANHO DO BANCO PELO BACKUP
SELECT
[database_name] AS "Database",
DATEPART(month,[backup_start_date]) AS "Month",
AVG([backup_size]/1024/1024) AS "Backup Size MB",
AVG([compressed_backup_size]/1024/1024) AS "Compressed Backup Size MB",
AVG([backup_size]/[compressed_backup_size]) AS "Compression Ratio"
FROM msdb.dbo.backupset
WHERE 
[type] = 'D'
GROUP BY [database_name],DATEPART(mm,[backup_start_date]);

-- histórico de atualizações de estatísticas 

WITH STATS  (ID, Tabela, StatsName, ultAtl, modific, dias, comando)
as
(
SELECT DISTINCT
      TB.object_id
      ,TB.name
      ,ST.name
      ,stats.last_updated
      ,stats.modification_counter
      ,(DATEDIFF(d,stats.last_updated ,getdate()) ) AS 'DiasDesatualizados'
      ,'UPDATE STATISTICS [' + sc.name + '].['+TB.name+'] ['+ST.name+'] WITH FULLSCAN' as 'command'
 FROM sys.tables TB
 inner join sys.schemas sc on
 sc.schema_id = TB.schema_id
INNER JOIN sys.stats ST ON TB.object_id = ST.object_id
INNER JOIN sys.indexes IX ON TB.object_id = IX.object_id
CROSS APPLY sys.dm_db_stats_properties(TB.object_id, ST.stats_id) as stats
--ORDER BY TB.name, ST.name
)
select * from STATS order by modific desc

------------------------------------------------------------------------

with x
as (
select
getdate() data, @@SERVERNAME server, db_name(db_id()) banco, s.name sX,
OBJECT_NAME(b.object_id) tabela, b.name Indice,
avg_fragmentation_in_percent MedPer , page_count PgNr, fill_factor ff
from sys.dm_db_index_physical_stats(  db_id(), null, null, null,null) A
inner join sys.indexes B
on a.object_id = b.object_id and A.index_id = B.index_id
inner join sys.tables t
on t.object_id = b.object_id
inner join sys.schemas S
on t.schema_id = s.schema_id)
select * from x
where MedPer > 30 and PgNr > 1000
ORDER BY x.MedPer desc

--Estatisticas desatualizadas por dia (Cada banco)
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
--ORDER BY TB.name, ST.name
)
select * from STATS order by comando
 
 
--Ajustada consulta para retornar o sampled de cada estatistica bem com a quantidade de linhas
WITH STATS  (ID, Tabela, StatsName, ultAtl, modific, dias, rows, rows_sampled, comando)
as
(
SELECT DISTINCT
       TB.object_id
       ,TB.name
       ,ST.name
       ,stats.last_updated
       ,stats.modification_counter
       ,(DATEDIFF(d,stats.last_updated ,getdate()) ) AS 'DiasDesatualizados'
       ,stats.rows
       ,stats.rows_sampled
       ,'UPDATE STATISTICS [' + sc.name + '].['+TB.name+'] ['+ST.name+'] WITH FULLSCAN' as 'command'
  FROM sys.tables TB
  inner join sys.schemas sc on
  sc.schema_id = TB.schema_id
 INNER JOIN sys.stats ST ON TB.object_id = ST.object_id
 INNER JOIN sys.indexes IX ON TB.object_id = IX.object_id
 CROSS APPLY sys.dm_db_stats_properties(TB.object_id, ST.stats_id) as stats
where (DATEDIFF(d,stats.last_updated ,getdate()) ) > 0
    and stats.modification_counter > 0
--ORDER BY TB.name, ST.name
)
select * from STATS
--where Tabela = 'corp_acompanha_rotina'
order by modific desc
 
------OU VERSAO ABAIXO (), adicionei apenas o SampleDone
 
SELECT object_name(stat.object_id) as Tabela, sp.stats_id, stat.name, filter_definition, last_updated, rows, rows_sampled, (rows_sampled*100)/rows as 'SampleDone(%)', steps, unfiltered_rows, modification_counter
FROM sys.stats AS stat
    CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
--WHERE stat.object_id = OBJECT_ID('Historico')
order by 'SampleDone(%)' desc
 

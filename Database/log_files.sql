-- tamanho de arquivos de log (exibe o espaço utilizado dos logs de todos os bancos)


DBCC SQLPERF(LOGSPACE)

-- tamanho de arquivos de log (exibe o espaço livre dos arquivos de todos os bancos)

declare @tbl as table(db_name varchar(2000), File_name varchar(200), Current_Size numeric(10,2), Free_Space numeric(10,2), [Free_Percent_Space%] numeric(10,2), [Aumentar paraMB] numeric(10,2))
insert into @tbl
exec sp_MSforeachdb  @command1 = 
' use ?
SELECT DB_NAME() AS DbName, 
name AS FileName, 
size/128.0 AS CurrentSizeMB, 
size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0 AS FreeSpaceMB,
((size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0)*100)/(size/128.0) as ''PercentSpace(%)'',
size/128.0 + (size/128.0 * 0.15) as ''Sugestao para aumento''
FROM sys.database_files;'
 
select *from @tbl

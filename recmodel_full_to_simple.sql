DECLARE @DatabaseName NVARCHAR(255)
DECLARE @SQL NVARCHAR(MAX)
 
-- Cursor para percorrer todos os bancos de dados que estão em FULL recovery model
DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE recovery_model_desc = 'FULL'
    AND database_id > 4  -- Exclui bancos do sistema (master, tempdb, model, msdb)
 
OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @DatabaseName
 
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Gerar comando para alterar o Recovery Model para SIMPLE
    SET @SQL = 'ALTER DATABASE [' + @DatabaseName + '] SET RECOVERY SIMPLE;
                PRINT ''Recovery Model alterado para SIMPLE em ' + @DatabaseName + ''''
                + CHAR(13) + CHAR(10)
 
    PRINT @SQL  -- Apenas imprime o comando, não executa
 
    FETCH NEXT FROM db_cursor INTO @DatabaseName
END
 
CLOSE db_cursor
DEALLOCATE db_cursor

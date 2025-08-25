--MOVIMENTAÇÃO DE ARQUIVOS DE DADOS DOS BANCOS
 
--fechar todas as conexões
ALTER DATABASE [Test] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
 
--definir banco de dados com status offline
ALTER DATABASE [Test] SET OFFLINE
 
--Para o novo caminho
 
ALTER DATABASE [Test] MODIFY FILE (NAME = Test, FILENAME = 'C:\DATA\Test.Mdf') --MOVIMENTAR ARQUIVOS MANUALMENTE PARA NOVA UNIDADE.
 
ALTER DATABASE [Test] MODIFY FILE (NAME = Test_log, FILENAME = 'C:\LOG\Test_log.ldf') --MOVIMENTAR ARQUIVOS MANUALMENTE PARA NOVA UNIDADE.
 
--definir banco de dados com status online
ALTER DATABASE [Test] SET ONLINE
 
--definir multiusuário
ALTER DATABASE [Test] SET MULTI_USER
 
/*SELECT PARA VERIFICAR DIRETÓRIO DOS ARQUIVOS*/
SELECT
D.name,
F.Name AS FileType,
F.physical_name AS PhysicalFile,
F.state_desc AS OnlineStatus,
CAST((F.size*8/1024)/1024 AS VARCHAR(26)) + ' GB' AS FileSize,
CAST(F.size*8 AS VARCHAR(32)) + ' Bytes' as SizeInBytes
FROM
sys.master_files F
INNER JOIN sys.databases D ON D.database_id = F.database_id
--where  D.name = 'treinamentoTSQL'
ORDER BY
D.name

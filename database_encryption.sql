--CHECK FOR EXISTING MASTER SYMMETRIC KEYS
select * from sys.symmetric_keys;
 
--CHECK FOR EXISTING CERTIFICATES 
select * from sys.certificates
--CHECK TO WHICH DATABASE ENCRYPTION KEY THE CERTIFICATE IS BOUND
USE [master]
GO
SELECT
DB_NAME(db.database_id) DbName, db.encryption_state
, encryptor_type, cer.name, cer.expiry_date, cer.subject
FROM sys.dm_database_encryption_keys db
JOIN sys.certificates cer 
ON db.encryptor_thumbprint = cer.thumbprint
GO
--CHECK ENCRYPTED DATABASES
select name, is_encrypted from sys.databases
 
--RETRIEVES DATABASES ENCRYPTION STATE 
SELECT DB_NAME([database_id]) AS 'Database Name',
   [encryption_state],
   encryption_state = CASE 
    WHEN encryption_state = 1
      THEN 'Descriptografado'
    WHEN encryption_state = 2
      THEN 'Criptografia em Progresso'
    WHEN encryption_state = 3
      THEN 'Criptografado'
    WHEN encryption_state = 4
      THEN 'Troca da chave em Progresso'
    WHEN encryption_state = 5
      THEN 'Descriptografia em Progresso'
    WHEN encryption_state = 6
      THEN 'Troca de Protecao em Progresso'
    WHEN encryption_state = 0
      THEN 'Database nao esta em processo de criptografia'
    END,
   [percent_complete],
   [encryption_state_desc],
   [encryption_scan_state],
   [encryption_scan_state_desc],
   [encryption_scan_modify_date],
   [create_date],
   [regenerate_date],
   [key_algorithm],
   [key_length],
   [modify_date],
   [set_date],
   [opened_date],
   [encryptor_thumbprint],
   [encryptor_type]
FROM [sys].[dm_database_encryption_keys]
 
 
--CREATE MASTER KEY
USE master
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'pass123'
GO
 
 
--CREATE A CERTIFICATE
USE master
GO
CREATE CERTIFICATE CertificadoTeste
WITH SUBJECT = 'Certificado de Criptografia Teste',
EXPIRY_DATE = '20280308'
GO
 
--BACKUP CERTIFICATE
BACKUP CERTIFICATE CertificadoTeste
TO FILE = 'C:\Cript....\....\...\CertificadoTeste.cer'
WITH PRIVATE KEY 
(
    FILE = 'C:\...\...\CertificadoTeste_MasterKey.pvk',
ENCRYPTION BY PASSWORD = 'pass123'
    );
GO
 
--RESTORE CERTIFICATE
USE master
GO
CREATE CERTIFICATE CertificadoTeste
FROM FILE  = 'C:\Cript....\....\...\CertificadoTeste.cer' WITH PRIVATE KEY
(
	FILE = 'C:\CDB\MSSQLSERVER\TDE\Cert_MasterKey.pvk', 
	DECRYPTION BY PASSWORD = 'pass123'
    );
GO
 
--CREATE DATABASE ENCRYPTION KEY (DEK) IN THE DATABASE WHERE TDE WILL BE ENABLED
USE [AdventureWorks2019]
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE CertificadoTeste;
GO
 
--ENABLE DATABASE ENCRYPTION
USE [AdventureWorks2019]
GO
ALTER DATABASE [AdventureWorks2019]
SET ENCRYPTION ON
 
--DISABLE DATABASE ENCRYPTION
USE [AdventureWorks2019]
GO
ALTER DATABASE [AdventureWorks2019]
SET ENCRYPTION OFF

--RESTORE SIMPLIFICADO

RESTORE FILELISTONLY 
FROM DISK = 'E:\Backup\MIGRACAO\BKF_dadoscons_teste.bak'


RESTORE DATABASE dadoscons 
FROM DISK = 'E:\Backup\MIGRACAO\BKF_dadoscons_teste.bak'
WITH 
MOVE 'dadoscons' TO 'I:\Dados\MSSQLSERVER\dadoscons.mdf' ,
MOVE 'dadoscons_log' TO 'F:\Log\MSSQLSERVER\dadoscons_log.ldf', 
RECOVERY,
STATS = 5

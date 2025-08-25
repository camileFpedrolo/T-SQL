--- BACKUP
SELECT  sd.name AS [Database],
        CASE WHEN bs.type = 'D' THEN 'Full backup'
             WHEN bs.type = 'I' THEN 'Differential'
             WHEN bs.type = 'L' THEN 'Log'
             WHEN bs.type = 'F' THEN 'File/Filegroup'
             WHEN bs.type = 'G' THEN 'Differential file'
             WHEN bs.type = 'P' THEN 'Partial'
             WHEN bs.type = 'Q' THEN 'Differential partial'
             ELSE 'Unknown (' + bs.type + ')'
        END AS [Backup Type],
        bs.backup_start_date AS [Date Start],
    bs.backup_finish_date AS [Date Finish],
    bs.backup_size ,
    bs.compressed_backup_size,
    (bs.backup_size/1024)/1024 as 'Backup Size [Mb]', 
    (bs.compressed_backup_size/1024)/1024 as 'Compressed Size [Mb]',
    bs.database_backup_lsn,
    bs.first_lsn,
    bmf.physical_device_name,
    bs.is_copy_only,
    bs.user_name
FROM    master..sysdatabases sd
        LEFT OUTER JOIN msdb..backupset bs ON RTRIM(bs.database_name) = RTRIM(sd.name)
        LEFT OUTER JOIN msdb..backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
where sd.name = 'crespidb'--and bs.type = 'L'
ORDER BY sd.name, [Date Start] desc

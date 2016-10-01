USE master
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'sp_getlastbackuprestore')
	EXEC ('CREATE PROC sp_getlastbackuprestore AS SELECT ''stub version, to be replaced''')
GO
/*********************************************************************************************
Last BackUp and Restore on DataBase v1 (09-29-2016)
(C) 2016, Dmitrii Baev

http://dmbaev.com

License: 
	free to download and use.
*********************************************************************************************/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_getlastbackuprestore] 
--If you need a certain base.
@BaseName VARCHAR(1000) = ''
AS
BEGIN
	SET NOCOUNT ON;

SELECT  @@Servername AS ServerName ,
        [db].[name] AS BaseName ,
        MAX([db_b].[backup_finish_date]) AS LastBackupCompleted,
		MAX([db_r].[restore_date]) AS LastRestoreCompleted
FROM    sys.databases db
        LEFT OUTER JOIN [msdb]..[backupset] db_b
                    ON [db_b].[database_name] = [db].[name]
                       AND ([db_b].[type] = 'D' or [db_b].[type] = 'I')
		LEFT OUTER JOIN [msdb]..[restorehistory] db_r
                    ON [db_r].[destination_database_name] = [db].[name]
                       AND ([db_r].[restore_type]='D' or [db_r].[restore_type]='I')		
								WHERE 
								[db].[name] LIKE
									  CASE 
									  WHEN @BaseName !=''
									   THEN 
										 @BaseName
										 ELSE '%'
										 END   
GROUP BY [db].[name]
ORDER BY [db].[name]							
END
GO

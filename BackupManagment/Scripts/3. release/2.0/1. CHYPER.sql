--select * from sys.symmetric_keys
USE master
GO  

If  not exists ( select 1 from sys.symmetric_keys 
                where name = '##MS_DatabaseMasterKey##')
BEGIN
		
			CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'StGPU4(qLx';
			

			CREATE CERTIFICATE DBBackupCertUWFS007  
			WITH SUBJECT = 'Backup Encryption Certificate';  
						
           BACKUP CERTIFICATE DBBackupCertUWFS007
           TO FILE = 'C:\TEMP\CertDBBackupUwfS007.cer'
           WITH PRIVATE KEY (FILE = 'c:\temp\EncryptPrivateFileUwfS007.prv',
           ENCRYPTION BY PASSWORD = '7rZ%UTQRqKBp6s[A')



END





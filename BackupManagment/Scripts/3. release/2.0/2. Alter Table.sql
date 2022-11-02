Use DbAdmin
go
alter table DBBackup.Config add Encrypt char(1)
go

update DBBackup.Config
set Encrypt = 'N'
go


Use DbAdmin
go
alter table DBBackup.Config add EncAlgorithm char(7)
go

update DBBackup.Config
set EncAlgorithm = 'AES_256'
go

Use DbAdmin
go
alter table DBBackup.Config add ServerCertificate char(50)
go


update DBBackup.Config
set ServerCertificate = NULL
go

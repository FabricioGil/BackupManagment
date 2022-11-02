Use DbAdmin
go
alter table DBBackup.Config add FilesNumber tinyint
go

update DBBackup.Config
set FilesNumber = 1
go


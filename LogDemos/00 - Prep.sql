use master;

alter database CorpDB set offline with rollback immediate;

restore database CorpDB from disk = 'C:\data\sql2016\backup\CorpDB.bak'
with replace;


use master;

alter database CorpDB set offline with rollback immediate;

restore database CorpDB from disk = 'C:\data\sql2016\backup\CorpDB.bak'
with move 'CorpDB' to 'c:\data\sql2016\data\CorpDB.mdf',
move 'CorpDB_log' to 'c:\data\sql2016\log\CorpDB_log.ldf',
replace;

alter database CorpDB set compatibility_level = 130;

/*
alter database CorpDB set recovery full;
backup database CorpDB to disk = 'nul';
backup log CorpDB to disk = 'nul';

alter database CorpDB set recovery simple;
*/

-----------------------------------------------------------------------------------------------------------------------
-- 01 - DbccLoginfo.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016-2017, Brian Hansen (brian@tf3604.com).
-- Version 1.0.2
-- Look for the most recent version of this script at www.tf3604.com/log.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
-- documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
-- the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions 
-- of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
-- TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
-- CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
-----------------------------------------------------------------------------------------------------------------------

-- DBCC LOGINFO
--   Returns a row for each VLF in the database
-- Input
--   Takes a single parameter, either a database name or a database ID.
-- Output
--   RecoveryUnitId - Purpose unknown (SQL 2012+)
--   FileId - The ID of the log file (see sys.database_files)
--   FileSize - The size of the VLF in bytes
--   StartOffset - The beginning offset of the VLF in the physical file
--   FSeqNo - The VLF number
--   Status - 0 = VLF is inactive, 2 = VLF is active
--   Parity - Either 0, 64 or 128.  Used for crash recovery
--   CreateLSN - 0 = VLF was created when the database was created; otherwise the LSN at the time the VLF was created.

dbcc loginfo ('CorpDB');

-- It is sometimes useful to capture the output of DBCC LOGINFO into a table.
-- Because the RecoveryUnitId may or may not exist due to the database version, we have
-- to do some extra work to have a script capture the output regardless of what version
-- we are running.  Here is one solution (create a temp table with a dummy column,
-- add the required columns based on the database version, the drop the dummy column).

declare @version varchar(50) = cast(serverproperty('ProductVersion') as varchar(50));
declare @dotPosition int = charindex('.', @version);
declare @majorVersion int = case when @dotPosition > 0 then cast(substring(@version, 1, @dotPosition - 1) as int) end;

if object_id('tempdb.dbo.#loginfo') is not null
	drop table #loginfo;
create table #loginfo
(
	DummyColumn int
);

if @majorVersion >= 11 -- SQL Server 2012 or higher.
begin
	alter table #loginfo
	add RecoveryUnitId int;
end

alter table #loginfo
add
	FileId int,
	FileSize bigint,
	StartOffset bigint,
	FSeqNo int,
	Status int,
	Parity tinyint,
	CreateLSN decimal(25,0);

alter table #loginfo
drop column DummyColumn;

insert #loginfo
exec ('dbcc loginfo');

select * from #loginfo;

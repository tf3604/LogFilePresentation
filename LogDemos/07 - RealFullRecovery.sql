-----------------------------------------------------------------------------------------------------------------------
-- 07 - RealFullRecovery.sql
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016-2017, Brian Hansen (brian@tf3604.com).
-- Version 1.0.4
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

-- Setup:
--    Start LogFileVisualizer and point it at CorpDB.

use CorpDB;
go

-- Verify that we're in FULL recovery.
select db.recovery_model_desc from sys.databases db where db.Name = 'CorpDB';
go

-- When we switch a database from SIMPLE to FULL recovery, it actually goes into a state commonly known
-- as psuedo-simple recovery.  However, there isn't really an easy way to see that this is the case.
-- Pseudo-simple recovery, as we have seen, behaves the same as SIMPLE recovery.
-- To get the database truely into the FULL recovery model, we need to take a full backup of the database.
-- Note that this will clear the log.

backup database CorpDB to disk = 'nul';

-- Execute the following statement to insert 10,000 records into the Customer table.
-- Observe the effects on the log.
-- Execute the statement a number of times and observe that the log now grows and cannot clear.

exec CorpDB.dbo.spGenerateRandomCustomers 10000;

-- Run the statement in a loop with a short delay between executions.
-- Stop after a few seconds.

while 0 = 0
begin;
	exec CorpDB.dbo.spGenerateRandomCustomers 10000;
	waitfor delay '0:00:01';
end;
go

-- If we now try to shrink the log back to 10 MB, nothing really happens.  It may remove a VLF at the end of the
-- log, but the active log records are still need and cannot be cleared.

dbcc shrinkfile (N'CorpDB_log' , 10, truncateonly);
go

-- So what needs to happen for the log to clear?  SQL gives us a clue:

select db.log_reuse_wait_desc from sys.databases db where db.Name = 'CorpDB';
go

-- Take a log backup.

backup log CorpDB to disk = 'nul';
go

-- Now shrink the database back to 10 MB.  Note that we may need to repeatedly backup the log and
-- shrink the database if the end of the log is still active.

dbcc shrinkfile (N'CorpDB_log' , 10, truncateonly);

-- Now let's run the workload in a loop again.  First, however, we need to kick off a process to take
-- regular log backups.  Start the script in file: 07b - BackupLog.sql

while 0 = 0
begin;
	exec CorpDB.dbo.spGenerateRandomCustomers 25000;
	waitfor delay '0:00:01';
end;
go

-- Eventually the log will reach a steady state where it no longers needs to grow.
-- Be sure to stop the workload.


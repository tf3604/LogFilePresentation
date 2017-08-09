-----------------------------------------------------------------------------------------------------------------------
-- 07 - ChangeToFullRecovery.sql
-- Version 1.0.4
-- Look for the most recent version of this script at www.tf3604.com/log.
-- MIT License; see bottom of this file for details.
-----------------------------------------------------------------------------------------------------------------------

-- Setup:
--    Start LogFileVisualizer and point it at CorpDB.
--    Make sure CorpDB is in the SIMPLE recovery model.
--    Shrink the log to 10 MB.

use CorpDB;
go
select db.recovery_model_desc from sys.databases db where db.Name = 'CorpDB';
go
dbcc shrinkfile (N'CorpDB_log', 10, truncateonly);
go

-- Now we'll switch the database to FULL recovery.

alter database CorpDB set recovery full;
go
select db.recovery_model_desc from sys.databases db where db.Name = 'CorpDB';
go

-- Execute the following statement to insert 10,000 records into the Customer table.
-- Observe the effects on the log.
-- Execute the statement a number of times and observe that the log does not grow.

exec CorpDB.dbo.spGenerateRandomCustomers 10000;

-- Run the statement in a loop with a short delay between executions.
-- Stop after a few seconds.

while 0 = 0
begin;
	exec CorpDB.dbo.spGenerateRandomCustomers 10000;
	waitfor delay '0:00:01';
end;
go

-- This behavior seems exactly the same as SIMPLE recovery.  What's going on here?

-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016-2017, Brian Hansen (brian at tf3604 dot com).
--
-- MIT License
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

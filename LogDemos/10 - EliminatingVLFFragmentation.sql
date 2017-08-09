-----------------------------------------------------------------------------------------------------------------------
-- 10 - EliminatingVLFFragmentation.sql
-- Version 1.0.4
-- Look for the most recent version of this script at www.tf3604.com/log.
-- MIT License; see bottom of this file for details.
-----------------------------------------------------------------------------------------------------------------------

-- Setup:
--    Start LogFileVisualizer and point it at CorpDB.

use CorpDB;
go

-- Having too many or too few VLFs can cause performance problems.
-- Also, ideally, we would pre-allocate the log rather than let it grow during user operations.
-- How many VLFs should the database have.  Generally 50 to 200 is considered good.
-- How big should each VLF be?  That depends greatly on the workload on the system, but an upper limit is generally
-- considered to be about 500 MB.

-- In this example, we will do a controlled growth of the log.
-- We will pre-allocate (about) 50 VLFs of 2 MB each (on real production systems, 2 MB is probably much too small).

-- Start by shrinking the log as much as possible.

dbcc shrinkfile (N'CorpDB_log' , 0, truncateonly);
go

-- Note that depending on where the active VLF is at the moment and how much activity is on the system, we may
-- need to repeatedly take log backups and repeat the shrink to really get things down to size.

backup log CorpDB to disk = 'nul';
go
dbcc shrinkfile (N'CorpDB_log' , 0, truncateonly);
go

-- Next we will set the size of the log to some good initial value.  Note that an 8 MB log growth will create 4 VLFs, so
-- they will be about 2 MB each.

alter database CorpDB modify file (name = N'CorpDB_log', size = 16mb);
go

-- And then we will continue to grow the log in 8mb increments.

alter database CorpDB modify file (name = N'CorpDB_log', size = 24mb);
go
alter database CorpDB modify file (name = N'CorpDB_log', size = 32mb);
go
alter database CorpDB modify file (name = N'CorpDB_log', size = 40mb);
go
alter database CorpDB modify file (name = N'CorpDB_log', size = 48mb);
go
alter database CorpDB modify file (name = N'CorpDB_log', size = 56mb);
go
alter database CorpDB modify file (name = N'CorpDB_log', size = 64mb);
go

-- After this point, growing the log in 8 MB increments on a SQL 2014+ system will add a single VLF that is 8 MB.

-- On SQL 2012 and earlier we would continue to grow in 8 MB chunks:
-- alter database CorpDB modify file (name = N'CorpDB_log', size = 72mb);
-- alter database CorpDB modify file (name = N'CorpDB_log', size = 80mb);
-- alter database CorpDB modify file (name = N'CorpDB_log', size = 88mb);
-- alter database CorpDB modify file (name = N'CorpDB_log', size = 92mb);
-- go

-- On SQL 2014+ we will need to start growing in 2 MB increments:
alter database CorpDB modify file (name = N'CorpDB_log', size = 66mb);
alter database CorpDB modify file (name = N'CorpDB_log', size = 68mb);
alter database CorpDB modify file (name = N'CorpDB_log', size = 70mb);
alter database CorpDB modify file (name = N'CorpDB_log', size = 72mb);
alter database CorpDB modify file (name = N'CorpDB_log', size = 74mb);
alter database CorpDB modify file (name = N'CorpDB_log', size = 76mb);
alter database CorpDB modify file (name = N'CorpDB_log', size = 78mb);
alter database CorpDB modify file (name = N'CorpDB_log', size = 80mb);
alter database CorpDB modify file (name = N'CorpDB_log', size = 82mb);
alter database CorpDB modify file (name = N'CorpDB_log', size = 84mb);
alter database CorpDB modify file (name = N'CorpDB_log', size = 86mb);
alter database CorpDB modify file (name = N'CorpDB_log', size = 88mb);
alter database CorpDB modify file (name = N'CorpDB_log', size = 90mb);
alter database CorpDB modify file (name = N'CorpDB_log', size = 92mb);
go

-- If we re-reun the final demo in script 07 (with regular log backups in progress) we will see that the
-- log never comes close to filling up and never needs to grow as a result of a user operation.

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

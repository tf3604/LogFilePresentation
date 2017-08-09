-----------------------------------------------------------------------------------------------------------------------
-- 09 - Rollbacks.sql
-- Version 1.0.4
-- Look for the most recent version of this script at www.tf3604.com/log.
-- MIT License; see bottom of this file for details.
-----------------------------------------------------------------------------------------------------------------------

use CorpDB;
go

-- Verify that we're in FULL recovery.
select db.recovery_model_desc from sys.databases db where db.Name = 'CorpDB';

if object_id('tempdb.dbo.#maxlsn') is not null
	drop table #maxlsn;
create table #maxlsn
(
	LSN nvarchar(25)
);
go

-- Save off the value of the current maximum LSN.
insert #maxlsn (LSN)
select top 1 N'0x' + [Current LSN] from fn_dblog(null, null) order by [Current LSN] desc;
go

-- Here is the current state of the log (just one unrelated record at the end of the log).
declare @maxlsn nvarchar(25) = (select top 1 LSN from #maxlsn);

select [Current LSN], Operation, Context, [Transaction ID], [Log Reserve], Description, [Previous LSN]
from fn_dblog(@maxlsn, null);
go

-- Let's start a transaction and do a couple of inserts (without .
begin transaction;

insert CorpDB.dbo.Customer (FirstName, LastName, Address, City, State)
values ('Vanessa', 'Leach', '5764 NE Bond Mill Rd', 'Vacaville', 'CA');

insert CorpDB.dbo.Customer (FirstName, LastName, Address, City, State)
values ('Tyrone', 'Banuelos', '13926 S Charmada Blvd', 'Virginia Beach', 'VA');
go

-- Paste the statement copied above.
declare @maxlsn nvarchar(25) = (select top 1 LSN from #maxlsn);

select [Current LSN], Operation, Context, [Transaction ID], [Log Reserve], Description, [Previous LSN]
from fn_dblog(@maxlsn, null);
go

-- Now undo the transaction, and see what gets added to the log.
rollback transaction;

declare @maxlsn nvarchar(25) = (select top 1 LSN from #maxlsn);

select [Current LSN], Operation, Context, [Transaction ID], [Log Reserve], Description, [Previous LSN]
from fn_dblog(@maxlsn, null);
go

-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2016-2017, Brian Hansen (brian at tf3604.com).
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

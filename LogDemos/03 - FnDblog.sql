-----------------------------------------------------------------------------------------------------------------------
-- 03 - FnDblog.sql
-- Version 1.0.4
-- Look for the most recent version of this script at www.tf3604.com/log.
-- MIT License; see bottom of this file for details.
-----------------------------------------------------------------------------------------------------------------------

-- fn_dblog(start_lsn, end_lsn)
--   Returns a row for each log record in the active portion of the SQL Server transaction log
-- Input
--   start_lsn - First LSN to be in the output.  If NULL, starts at the beginning of the active portion of the log.
--   end_lsn - Last LSN to be in the output.  If NULL, ends at the finish of the active portion of the log.
-- Output
--   About 130 columns of output related to the transaction log

use CorpDB;

select *
from fn_dblog(null, null);

-- Input LSNs are either "decimal separated" or "hexadecimal separated" with an "0x" prefix.
-- Identify a pair of begin and end LSN values from the previous output and plug them into the following
-- statements.  In the first statement the values will need to be converted to decimal-separated,
-- and in the second statement the values will need to be prefixed with '0x'.

select *
from fn_dblog('285:1568:124', '285:1688:29');

select *
from fn_dblog('0x0000011d:00000620:007c', '0x0000011d:00000698:001d');

go
-- Get the 100th and 200th LSN from the log, then select just that range.
declare @startLsn nvarchar(25);
declare @endLsn nvarchar(25);

with LsnList as
(
	select top 100 [Current LSN]
	from fn_dblog(null, null)
	order by [Current LSN]
)
select top 1 @startLsn = N'0x' + [Current LSN]
from LsnList
order by [Current LSN] desc;

with LsnList as
(
	select top 100 [Current LSN]
	from fn_dblog(@startLsn, null)
	order by [Current LSN]
)
select top 1 @endLsn = N'0x' + [Current LSN]
from LsnList
order by [Current LSN] desc;

declare @sql nvarchar(max) = 'select *
from fn_dblog(' + isnull('''' + @startLsn + '''', 'null') + ', ' + isnull('''' + @endLsn + '''', 'null') + ');';

print @sql;

select *
from fn_dblog(@startLsn, @endLsn);
go

-- By default, fn_dblog only returns records from the active portion of the log.  If trace flag 2537 is enabled,
-- fn_dblog will return records from the inactive portion as well.

dbcc traceon (2537);

select *
from fn_dblog(null, null);

dbcc traceoff (2537);

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

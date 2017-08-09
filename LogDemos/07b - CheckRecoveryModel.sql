-----------------------------------------------------------------------------------------------------------------------
-- 07b - CheckRecoveryModel.sql
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
--    N/A

-- There isn't really a simple way to determine if a database is in "auto-truncate" mode.
-- If the DB is in Full recovery but doesn't have a full backup since it was switched into Full recovery,
-- the DB still behaves as if it is in Simple recovery as far as log truncation is concerned.
-- How do we determine if this is the case?

use CorpDB;

dbcc traceon (3604);

declare @page table
(
	ParentObject nvarchar(255),
	Object nvarchar(255),
	Field nvarchar(255),
	Value nvarchar(4000)
);

insert @page
exec ('declare @n nvarchar(255) = db_name(); dbcc page (@n, 1, 9, 3) with tableresults;');

declare @lastBackupLSN nvarchar(4000) = (select top 1 Value from @page where Field = 'dbi_dbbackupLSN');
declare @isAutoTruncate bit = case when @lastBackupLSN = '0:0:0 (0x00000000:00000000:0000)' then 1 else 0 end;

select db.recovery_model_desc RecoveryModel, @isAutoTruncate IsAutoTruncate,
	case when db.recovery_model_desc in ('FULL', 'BULK_LOGGED') and @isAutoTruncate = 1 then 'PSEUDO_SIMPLE' else db.recovery_model_desc end ActualRecoveryModel
from sys.databases db
where db.database_id = db_id();

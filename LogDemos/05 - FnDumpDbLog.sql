-----------------------------------------------------------------------------------------------------------------------
-- 05 - FnDumpDbLog.sql
-- Version 1.0.5
-- Look for the most recent version of this script at www.tf3604.com/log.
-- MIT License; see bottom of this file for details.
-----------------------------------------------------------------------------------------------------------------------

-- fn_dump_dblog(start_lsn, end_lsn)
--   Returns a row for each log record in the transaction log backup.
-- Input
--   start_lsn - First LSN to be in the output.  If NULL, starts at the beginning of the backup.
--   end_lsn - Last LSN to be in the output.  If NULL, ends at the finish of the backup.
--   backup_type - 'DISK' or 'TAPE' (or null).
--   backup_number - Usually 1, unless backup contain multiple backups.
--   file_name - Name of the backup file.
--   file_name_2, file_name_3 ... file_name_64 - A total of 63 additional filenames (if backup spans multiple files).
--      Usually specify null or default here.
-- Output
--   About 130 columns of output related to the transaction log

select *
from fn_dump_dblog (null, null, 'DISK', 1,  'C:\data\sql2016\backup\CorpDB.20160802_2143.trn',
	null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, 
	null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
	null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, 
	null, null, null, null, null, null, null, null, null);

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

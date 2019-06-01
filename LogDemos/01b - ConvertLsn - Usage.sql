-----------------------------------------------------------------------------------------------------------------------
-- 01b - ConvertLsn - Usage.sql
-- Version 1.0.5
-- Look for the most recent version of this script at www.tf3604.com/log.
-- MIT License; see bottom of this file for details.
-----------------------------------------------------------------------------------------------------------------------

use CorpDB;
go

select * from dbo.ConvertLsn('0000011d:00000295:005b', 'Colon-separated hexadecimal');
select * from dbo.ConvertLsn('285:661:91', 'Colon-separated decimal');
select * from dbo.ConvertLsn('0x0000011D00000295005B', 'Hexadecimal');
select * from dbo.ConvertLsn('285000000066100091', 'Decimal');
go

-- Here is a function that outputs some LSNs in colon-separated hexadecimal format.
select top 100 dbl.[Current LSN]
from fn_dblog(null, null) dbl;

-- Can use the ConvertLsn function to get alternate representations.
select top 100 dbl.[Current LSN], lsn.Hexadecimal, lsn.ColonSeparatedDecimal
from fn_dblog(null, null) dbl
cross apply dbo.ConvertLsn(dbl.[Current LSN], 'Colon-separated hexadecimal') lsn;

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

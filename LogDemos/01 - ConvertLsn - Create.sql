-----------------------------------------------------------------------------------------------------------------------
-- 01 - ConvertLsn - Create.sql
-- Version 1.0.0
-- Look for the most recent version of this script at www.tf3604.com/log.
-- MIT License; see bottom of this file for details.
-----------------------------------------------------------------------------------------------------------------------

-- This script create an inline table-valued user-defined function called dbo.ConvertLsn (and some
-- helper function called dbo.Internal*) that will convert a LSN between different formats.

-- IMPORTANT: This is very raw code at this point (originally created 8/8/2017) and *VERY LIKELY*
-- contains bugs and limited error handling.  Please let me know of any problems you might encounter.
-- For the most up-to-date version of this script, see:
-- https://github.com/tf3604/LogFilePresentation/blob/master/LogDemos/01%20-%20ConvertLsn%20-%20Create.sql

-- This script uses features that require at least SQL Server 2012.

-- USAGE:
--		select * from dbo.ConvertLsn(@lsn, @inputType)
--			@lsn - nvarchar(25) - A string representing an LSN, formatted as indicated by @inputType.
--			@inputType - nvarchar(30) - Indicates the format of the LSN, and can be of these values:
--				'Colon-separated hexadecimal' - The LSN in the format of 'XXXXXXXX:XXXXXXXX:XXXX', such as: '0000011d:00000295:005b'.
--				'Colon-separated decimal' - The LSN in the format of 'DDDD:DDD:DDD', such as '285:661:91'.
--				'Hexadecimal' - The LSN in the format of '0xXXXXXXXXXX', such as '0x0000011D00000295005B'.
--				'Decimal' - The LSN in the format of 'DDDDDDDDDDDDDDD', such as '285000000066100091'.
-- OUTPUT:
--		This a table-valued function that returns these columns.
--			InputLsn - nvarchar(25) - Echoes the value of the @lsn input parameter.
--			InputType - nvarchar(30) - Echoes the value of the @inputType input parameter.
--			ColonSeparatedHexadecimal - nvarchar(22) - The input LSN represented as a colon-separated hexadecimal value.
--			ColonSeparatedDecimal - nvarchar(25) - The input LSN represented as a colon-separated decimal value.
--			Hexadecimal - varbinary(25) - The input LSN represented as a hexadecimal (binary) value.
--			Decimal - decimal(25, 0) - The input LSN represented as a decimal value.
-- EXAMPLES:
--		select * from dbo.ConvertLsn('0000011d:00000295:005b', 'Colon-separated hexadecimal');
--		select * from dbo.ConvertLsn('285:661:91', 'Colon-separated decimal');
--		select * from dbo.ConvertLsn('0x0000011D00000295005B', 'Hexadecimal');
--		select * from dbo.ConvertLsn('285000000066100091', 'Decimal');

use CorpDB;
go

-- Split colon-separated hexadecimal into parts
if exists (select * from sys.objects where name = 'InternalSeparatedHexToParts' and type = 'IF')
	drop function dbo.InternalSeparatedHexToParts;
go

create function dbo.InternalSeparatedHexToParts
(
	@lsn nvarchar(25)
)
returns table
as
return
with Parts as
(
	select case when len(@lsn) > 2 and substring(@lsn, 1, 2) = '0x' then 3 else 1 end Boundary
	union all
	select n.n + 1
	from Admin.dbo.Nums n
	where n.n < len(@lsn)
	and substring(@lsn, n.n, 1) = ':'
	union all
	select len(@lsn) + 2
), PartsWithBounds as
(
	select *, lead(Boundary) over (order by Boundary) NextBoundary
	from Parts
), ThreeParts as
(
	select
		substring(@lsn, Boundary, NextBoundary - Boundary - 1) PartHex,
		cast(convert(varbinary, '0x' + substring(@lsn, Boundary, NextBoundary - Boundary - 1), 1) as int) PartDecimal,
		row_number() over (order by Boundary) seq
	from PartsWithBounds
	where NextBoundary is not null
)
select isnull((select p.PartDecimal from ThreeParts p where p.seq = 1), 0) Part1,
	isnull((select p.PartDecimal from ThreeParts p where p.seq = 2), 0) Part2,
	isnull((select p.PartDecimal from ThreeParts p where p.seq = 3), 0) Part3;
go

-- Split colon-separated decimal into partsdeclare @lsn nvarchar(25) = '0x0000011d:00000295:005b';
if exists (select * from sys.objects where name = 'InternalSeparatedDecimalToParts' and type = 'IF')
	drop function dbo.InternalSeparatedDecimalToParts;
go

create function dbo.InternalSeparatedDecimalToParts
(
	@lsn nvarchar(25)
)
returns table
as
return
with Parts as
(
	select case when len(@lsn) > 2 and substring(@lsn, 1, 2) = '0x' then 3 else 1 end Boundary
	union all
	select n.n + 1
	from Admin.dbo.Nums n
	where n.n < len(@lsn)
	and substring(@lsn, n.n, 1) = ':'
	union all
	select len(@lsn) + 2
), PartsWithBounds as
(
	select *, lead(Boundary) over (order by Boundary) NextBoundary
	from Parts
), ThreeParts as
(
	select
		substring(@lsn, Boundary, NextBoundary - Boundary - 1) PartHex,
		cast(substring(@lsn, Boundary, NextBoundary - Boundary - 1) as int) PartDecimal,
		row_number() over (order by Boundary) seq
	from PartsWithBounds
	where NextBoundary is not null
)
select isnull((select p.PartDecimal from ThreeParts p where p.seq = 1), 0) Part1,
	isnull((select p.PartDecimal from ThreeParts p where p.seq = 2), 0) Part2,
	isnull((select p.PartDecimal from ThreeParts p where p.seq = 3), 0) Part3;
go
if exists (select * from sys.objects where name = 'InternalHexToParts' and type = 'IF')
	drop function dbo.InternalHexToParts;
go

create function dbo.InternalHexToParts
(
	@lsn nvarchar(25)
)
returns table
as
return
select *
from dbo.InternalSeparatedHexToParts(substring(@lsn, 1, len(@lsn) - 12) + ':' + substring(@lsn, len(@lsn) - 11, 8) + ':' + substring(@lsn, len(@lsn) - 3, 4));
go
if exists (select * from sys.objects where name = 'InternalDecimalToParts' and type = 'IF')
	drop function dbo.InternalDecimalToParts;
go

create function dbo.InternalDecimalToParts
(
	@lsn decimal(25, 0)
)
returns table
as
return
select *
from dbo.InternalSeparatedDecimalToParts(substring(cast(@lsn as nvarchar(25)), 1, len(cast(@lsn as nvarchar(25))) - 15) + ':' + substring(cast(@lsn as nvarchar(25)), len(cast(@lsn as nvarchar(25))) - 14, 10) + ':' + substring(cast(@lsn as nvarchar(25)), len(cast(@lsn as nvarchar(25))) - 4, 5));
go

if exists (select * from sys.objects where name = 'InternalLsnToParts' and type = 'IF')
	drop function dbo.InternalLsnToParts;
go

create function dbo.InternalLsnToParts
(
	@lsn nvarchar(25),
	@inputType nvarchar(30)
)
returns table
as
return
select
	case @inputType
		when 'Colon-separated hexadecimal' then sephex.Part1
		when 'Colon-separated decimal' then sepdec.Part1
		when 'Hexadecimal' then hex.Part1
		when 'Decimal' then dec.Part1
	end Part1,
	case @inputType
		when 'Colon-separated hexadecimal' then sephex.Part2
		when 'Colon-separated decimal' then sepdec.Part2
		when 'Hexadecimal' then hex.Part2
		when 'Decimal' then dec.Part2
	end Part2,
	case @inputType
		when 'Colon-separated hexadecimal' then sephex.Part3
		when 'Colon-separated decimal' then sepdec.Part3
		when 'Hexadecimal' then hex.Part3
		when 'Decimal' then dec.Part3
	end Part3
from dbo.InternalSeparatedHexToParts(case when @inputType = 'Colon-separated hexadecimal' then @lsn else '00000001:00000000:0000' end) sephex
outer apply dbo.InternalSeparatedDecimalToParts(case when @inputType = 'Colon-separated decimal' then @lsn else '1:0:0' end) sepdec
outer apply dbo.InternalHexToParts(case when @inputType = 'Hexadecimal' then @lsn else '0x01000000000000' end) hex
outer apply dbo.InternalDecimalToParts(case when @inputType = 'Decimal' then cast(@lsn as decimal(25,0)) else 1000000000000000 end) dec
go
if exists (select * from sys.objects where name = 'ConvertLsn' and type = 'IF')
	drop function dbo.ConvertLsn;
go

create function dbo.ConvertLsn
(
	@lsn nvarchar(25),
	@inputType nvarchar(30)
)
returns table
as
return
select
	@lsn InputLsn,
    @inputType InputType,
	lower(substring(convert(nvarchar(25), cast(lsn.Part1 as varbinary(20)), 1), 3, 8) + ':' +
		substring(convert(nvarchar(25), cast(lsn.Part2 as varbinary(20)), 1), 3, 8) + ':' +
		substring(convert(nvarchar(25), cast(lsn.Part3 as varbinary(20)), 1), 7, 4)) ColonSeparatedHexadecimal,
	cast(lsn.Part1 as nvarchar(25)) + ':' + 
		cast(lsn.Part2 as nvarchar(25)) + ':' + 
		cast(lsn.Part3 as nvarchar(25)) ColonSeparatedDecimal,
	convert(varbinary(25), '0x' + substring(convert(nvarchar(25), cast(lsn.Part1 as varbinary(20)), 1), 3, 8) + 
		substring(convert(nvarchar(25), cast(lsn.Part2 as varbinary(20)), 1), 3, 8) +
		substring(convert(nvarchar(25), cast(lsn.Part3 as varbinary(20)), 1), 7, 4), 1) Hexadecimal,
	cast(lsn.Part1 as decimal(25,0)) * 1000000000000000 +
		cast(lsn.Part2 as decimal(25,0)) * 100000 +
		cast(lsn.Part3 as decimal(25,0)) [Decimal]
from dbo.InternalLsnToParts(@lsn, @inputType) lsn;
go

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

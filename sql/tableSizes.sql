CREATE TABLE #tmpTableSizes
(
    tableName varchar(100),
    numberofRows varchar(100),
    reservedSize varchar(50),
    dataSize varchar(50),
    indexSize varchar(50),
    unusedSize varchar(50)
)
insert #tmpTableSizes
EXEC sp_MSforeachtable @command1="EXEC sp_spaceused '?'"


select DB_NAME(), * from #tmpTableSizes
order by cast(LEFT(reservedSize, LEN(reservedSize) - 4) as int)  desc

drop table #tmpTableSizes
/**  SaaS Query Logic Version 1.6 */
/**
 * Get volume counts from the main pre-import tables
 * 
 *
 */


DECLARE @USELOCALHOST BIT = 0 -- comment out the next line if you need/want to
SELECT @USELOCALHOST = CASE WHEN @@servername like 'S_WFASQLCINST%' THEN 0 ELSE 1 END 

DECLARE @PRINT_SQL BIT = 0 -- writes some debug information to the output messages, disable when setting up in production.

/** ****************************************************************************************************************** */
/**                Add Your SQL HERE                                                                                   */
/** ****************************************************************************************************************** */
/**
 * The dbName output will be added automaticly and it should NOT be part of your SQL. 
 * No variables really should be in this query and since they aren't defined until later... your script will fail 
 *    if you try to add them here.
 *
 * If you really must know the DB Name, use {{dbName}} in your code and it will be replaced. 
 *    Note - this value is already being returned as [dbName] so this is only really here 
 *    to extract the CO Code if it is essential. This will always return the Reporting Database name
 *    even when the System Database is being queried. You need to enclose in quotes if you're trying to return the string itself.
 * If you need the System database name, use {{dbNameSystem}} which will always be the system database name, 
 *    even when you are querying from the Reporting Database. You need to enclose in quotes if you're trying to return the string itself.
 *
 * IMPORTANT: Your SQL MUST have the eThorityUser schema, so " eThorityUser.TABLE_NAME " on all tablename references. 
 *    If this is missing anywhere the query will fail, frogs will fall from the sky and anit-matter will quickly form in
 *    the datacenter. Don't be a loser: use schema names!
 *
 */

DECLARE @sql NVARCHAR(MAX) = ' 

Put your SQL code here
 '
 
 /**
  * To Query System Databases, set the below bit to 1, otherwise leave it as zero.
  * The [dbName] will still return the Reporting Database since that's what will match to the "Instances" DR
  * No, you cannot query both in the same query
  */
 DECLARE @UseSystemDatabaseInstead BIT = 0
 /**
  * If, for whatever reason, checking for the presence of WFH_Controlled_Group isn't enough to ensure that the query runs, 
  *  you can add a different table name as the @TableToCheckIfACAMP. If the table doesn't exist, the database won't be queried at all
  */
 DECLARE @TableToCheckIfACAMP NVARCHAR(63) = N'WFH_PREIMPORT_Employee' 
 /**
  * If you need to use Common Table Expressions... the CTE MUST BE NAMED "SaaSCTE"
  *    and must be the first source in the FROM statement: the string "FROM SaaSCTE" must be found or else the temp table
  *    can't be built. If not using CTE, the CTE string should be left empty so @CTESQL = ''
  */
 DECLARE @CTESQL NVARCHAR(max) = ''
 
/**                 STOP!!!!                                                                                            */
/**            You are done. If you touch things below here you'll be beaten silly with a sack full of batteries        */
/** ******************************************************************************************************************  */














/**       WTF Dude!  Scroll back up.... this isn't your concern... this isn't the code you're looking for               */
/** ******************************************************************************************************************  */

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;


DECLARE @QueryUsesCommonTableExpressions BIT = 0
SELECT @QueryUsesCommonTableExpressions = CASE WHEN len(ltrim(rtrim(@CTESQL))) > 0 THEN 1 ELSE 0 END

IF @TableToCheckIfACAMP = N'' 
 SET @TableToCheckIfACAMP = N'WFH_Control_Groups' 

IF @PRINT_SQL = 1
 BEGIN
  print ' -- Provided SQL Start/ --------------------------'
  print @sql
  print ' -- Provided SQL /End ----------------------------'
 END
/**
 * Create temp table to track each DataBase that we'll inspect. 
 */
IF OBJECT_ID ('tempdb..#dbNames', N'U') IS NOT NULL 
BEGIN
  DROP TABLE #dbNames
END
  
CREATE TABLE #dbNames (dbName NVARCHAR(255), IsACA BIT)


/**
 * Get the databases - get all for now, we'll reduce this more in a moment
 */
INSERT INTO #dbNames 
SELECT 
    [name] as dbName
  , 0 as IsACA
FROM SYS.DATABASES 
WHERE 1=1
  AND 
  (
     ( [name] LIKE 'WFA[0-9][0-9][0-9][0-9][0-9][_]eThorityReporting' AND @USELOCALHOST = 0 )  -- Production
     OR 
     ( [name] LIKE '%[_]eThorityReporting' AND @USELOCALHOST = 1 )  -- localhost
  )
  AND [name] NOT IN ('WFA00002_eThorityReporting', 'WFA00005_eThorityReporting', 'WFA00012_eThorityReporting', 'WFA00020_eThorityReporting')

/**
 * A few variables for the Database list cursor
 * these get used and overwritten throughout.
 */
DECLARE @dbName NVARCHAR(255)
      , @firstDbName NVARCHAR(255)
      , @TempTable VARCHAR(255)
      , @SaaSQL NVARCHAR(max)

/** 
 * Loop through and determine which are ACA clients.
 *
 * Most queries will fail if the ACA Schema isn't in place, so this cursor checks to see 
 *    if the schema has WFH tables and updates the #dbNames table's IsACA bit.
 * The main query that is defined above will only run against the databases flagged as ACA
 */
DECLARE EachDatabase CURSOR FOR 
 SELECT [dbName] FROM #dbNames

OPEN EachDatabase 
FETCH NEXT FROM EachDatabase INTO @dbName

WHILE @@FETCH_STATUS <> -1
BEGIN
  SET @SaaSQL = 'UPDATE #dbNames SET IsACA = CAST(( SELECT COUNT(1) FROM [' + @dbName + '].SYS.TABLES WHERE [TYPE]=''U'' AND [NAME]=''' + @TableToCheckIfACAMP + ''' ) as BIT) WHERE dbName = ''' + @dbName + ''' '
  SET @SaaSQL = 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;
      ' + @SaaSQL 
  BEGIN TRY 
    EXEC(@SaaSQL)
  END TRY
  BEGIN CATCH
    print 'Failed to test if the database is an ACAMP database for Database: ''' + @dbName +'''.'
  END CATCH
  FETCH NEXT FROM EachDatabase INTO @dbName
END

CLOSE EachDatabase
DEALLOCATE EachDatabase

/**
 * #dbNames is now set and indicates which databases are ACA. We'll use this to cursor through and execute the desired query 
 */



/**
  *  Use the first Database on the list to help define the schema of the temp table.
  *  This allows the CURSOR to simply INSERT results and the temp table schema is dynamic based on the @sql variable
  *  We'll also generate a name for the temp table - it's a ## table to allow global scope
  */
SELECT TOP 1 @firstDbName = CASE WHEN @UseSystemDatabaseInstead = 1 THEN REPLACE(dbName,'Reporting','System') ELSE dbName END FROM #dbNames WHERE IsACA = 1 
SET @TempTable = QUOTENAME('##SaaSMetrics' + REPLACE(CONVERT(Varchar(36), newid()),'-','')) -- I just don't like hyphens in the table name :-)

IF @PRINT_SQL = 1
 BEGIN
  print ' -- Temp Table is called: Start/ --------------------------'
  print @TempTable
  print ' -- Temp Table /End ----------------------------'
 END
/**
 * This DSQL will run the query defined above as @sql to build the schema. 
 * the [dbName] is added at this point.
 * [eThorityUser]. and eThorityUser. are replaced here as well to include the full database path
 * Lastly, the special {{dbName}} is replaced by @dbName if necessary
 */
IF @QueryUsesCommonTableExpressions = 1
 BEGIN
  SET @SaaSQL = @CTESQL + ' ' + REPLACE(@sql, 'FROM SaaSCTE', ' INTO ' + @TempTable + ' FROM SaaSCTE')
 END
ELSE
 BEGIN
  SET @SaaSQL = ' SELECT TOP 1 * INTO ' + @TempTable + ' FROM (' + @sql + ') SaaS  '
 END
SET @SaaSQL = REPLACE(@SaaSQL, ' [eThorityUser].', ' [' + @firstDbName + '].[eThorityUser].') 
SET @SaaSQL = REPLACE(@SaaSQL, ' eThorityUser.', ' [' + @firstDbName + '].[eThorityUser].') 
SET @SaaSQL = REPLACE(@SaaSQL, '{{dbName}}', @firstDbName) 
SET @SaaSQL = REPLACE(@SaaSQL, '{{dbNameSystem}}', REPLACE(@firstDbName,'Reporting','System')) 

SET @SaaSQL = 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;
    ' + @SaaSQL 

IF @PRINT_SQL = 1
 BEGIN
    print '-- SQL to generate temp start/ -----------------------'
    print @SaaSQL
    print '-- SQL to generate temp /end -----------------------'
 END

BEGIN TRY
  -- build and handle the temp table.
  
  EXEC( @SaaSQL )
  -- now that the schema is set, let's truncate so that we don't duplicate results when the cursor runs
  SET @SaaSQL = 'TRUNCATE TABLE ' + @TempTable + ';'
  EXEC( @SaaSQL )
  -- add the dbName field that we'll automatically append.
  SET @SaaSQL = 'ALTER TABLE ' + @TempTable + ' ADD [dbName] NVARCHAR(255) NULL;' 
  EXEC( @SaaSQL )

END TRY
BEGIN CATCH
  -- handle case where we failed to build the temp table
  print 'failed to build temp table - nothing is going to happen. Attempted to use database ''' + @firstDbName + ''' to build table ''' + @TempTable + '''.'
END CATCH







/**
 * Finally... we'll cursor through each ACA Database and run the desired Query.
 */
DECLARE EachDatabase CURSOR FOR 
 SELECT [dbName] FROM #dbNames WHERE IsACA = 1

OPEN EachDatabase 
FETCH NEXT FROM EachDatabase INTO @dbName

WHILE @@FETCH_STATUS <> -1 and OBJECT_ID ('tempdb..' + @TempTable, N'U') IS NOT NULL 
BEGIN
 SET @SaaSQL = REPLACE(@sql, ' eThorityUser.', ' [eThorityUser].')
 SET @SaaSQL = REPLACE(@SaaSQL, ' [eThorityUser].', ' [' + CASE WHEN @UseSystemDatabaseInstead = 1 THEN REPLACE(@dbName,'Reporting','System') ELSE @dbName END + '].[eThorityUser].') 
 SET @SaaSQL = ' INSERT INTO ' + @TempTable + ' SELECT SaaS.*, ''' + @dbName + ''' as dbName FROM ( ' + @SaaSQL + ') SaaS ;'  
 SET @SaaSQL = REPLACE(@SaaSQL, '{{dbName}}', @dbName) 
 SET @SaaSQL = REPLACE(@SaaSQL, '{{dbNameSystem}}', REPLACE(@dbName,'Reporting','System')) 
 
 IF @QueryUsesCommonTableExpressions = 1
 BEGIN
   SET @SaaSQL = REPLACE( REPLACE(@CTESQL, ' eThorityUser.', ' [eThorityUser].')
                    , ' [eThorityUser].'
                    , ' [' + CASE WHEN @UseSystemDatabaseInstead = 1 THEN REPLACE(@dbName,'Reporting','System') ELSE @dbName END + '].[eThorityUser].')
            + ' ' + @SaaSQL  
 END

SET @SaaSQL = 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;
    ' + @SaaSQL 

 IF @PRINT_SQL = 1
 BEGIN
   print '-- SQL to get the data Start/ -------------------------------'
   print @SaaSQL
   print '-- SQL to get the data /End -------------------------------'
 END

BEGIN TRY
  EXEC( @SaaSQL )
END TRY
BEGIN CATCH
  print 'Failed to fetch results for ''' + @dbName + '''.'
END CATCH

-- don't need to print the SQL for every DB in the loop:
SET @PRINT_SQL = 0

-- continue with loop
  FETCH NEXT FROM EachDatabase INTO @dbName
END

CLOSE EachDatabase
DEALLOCATE EachDatabase



IF OBJECT_ID ('tempdb..'+@TempTable, N'U') IS NOT NULL 
BEGIN
  -- get the results
  SET @SaaSQL = 'SELECT * FROM ' + @TempTable 
  EXEC ( @SaaSQL ) 

  -- clean up, you're done.
  SET @SaaSQL = 'DROP TABLE ' + @TempTable
  EXEC ( @SaaSQL ) 
END
ELSE
BEGIN
  SELECT 'ERROR' as dbName  
END

IF OBJECT_ID ('#dbNames', N'U') IS NOT NULL 
BEGIN
  DROP TABLE #dbNames
END


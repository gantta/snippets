
DECLARE @var1 nvarchar(255)
		,@var2 nvarchar(255)

DECLARE myCursor CURSOR FOR
SELECT <...>
FROM [source]

OPEN myCursor

FETCH NEXT FROM myCursor INTO @var1, @var2


WHILE @@FETCH_STATUS <> -1
BEGIN
	/* Do some stuff here */


	-- reset loop
	FETCH NEXT FROM myCursor INTO @var1, @var2

END

/* Cursor cleanup */
CLOSE myCursor
DEALLOCATE myCursor



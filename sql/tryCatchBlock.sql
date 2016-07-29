 	BEGIN TRY
--		BEGIN TRANSACTION; 
    exec(@sqlexec)
--		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		SELECT @ErrorMessage = ERROR_MESSAGE() , @ErrorSeverity = ERROR_SEVERITY() , @ErrorState = ERROR_STATE();
--		ROLLBACK TRANSACTION;
		RAISERROR(@ErrorMessage , @ErrorSeverity , @ErrorState );
		BREAK;
	END CATCH 

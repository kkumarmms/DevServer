SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_DeleteInstitution]
	@Requestor VARCHAR(25) = 'MMSAdmin',
	@InstitutionID int = 0,
	@UpdatedBy varchar(50) 
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
				IF EXISTS (
					SELECT Inst.InstitutionID 
					FROM opr.Institution Inst 
					WHERE Inst.InstitutionID = @InstitutionID
						AND @InstitutionID > 0				)
				BEGIN
				  BEGIN TRY
					UPDATE opr.Institution 
					SET 
					   DateUpdated = GETDATE(),
					   IsDeleted = 'Y',
					   UpdatedBy = @UpdatedBy
					WHERE InstitutionID = @InstitutionID
        
					SELECT TOP 1 
					 [InstitutionID]
					  ,[InstitutionName]
					  ,[Address1]
					  ,[Address2]
					  ,[City]
					  ,[State]
					  ,[Zip]
					  ,[Phone]
					  ,[Email]
					  ,[Website]
					  ,[DateInserted]
					  ,[DateUpdated]
					  ,[IsDeleted]
					  ,[InsertedBy]
					  ,[UpdatedBy]
					FROM opr.Institution Inst 
					WHERE Inst.InstitutionID = @InstitutionID

  					SELECT 0 ERRORCODE, 'Successful.' ERRORMESSAGE
					END TRY
					BEGIN CATCH
						SELECT TOP 1 
								[InstitutionID]
								,[InstitutionName]
								,[Address1]
								,[Address2]
								,[City]
								,[State]
								,[Zip]
								,[Phone]
								,[Email]
								,[Website]
								,[DateInserted]
								,[DateUpdated]
								,[IsDeleted]
								,[InsertedBy]
								,[UpdatedBy]
						FROM opr.Institution Inst 
						WHERE Inst.InstitutionID = @InstitutionID

						 SELECT -100 ERRORCODE, ERROR_MESSAGE() ERRORMESSAGE
					END CATCH
				END
				ELSE
				BEGIN 
						SELECT TOP 1 
								[InstitutionID]
								,[InstitutionName]
								,[Address1]
								,[Address2]
								,[City]
								,[State]
								,[Zip]
								,[Phone]
								,[Email]
								,[Website]
								,[DateInserted]
								,[DateUpdated]
								,[IsDeleted]
								,[InsertedBy]
								,[UpdatedBy]
						FROM opr.Institution Inst 
						WHERE Inst.InstitutionID = @InstitutionID

						 SELECT -200 ERRORCODE, 'No record with the InstitutionID provided exists.' ERRORMESSAGE
				END		
			
		
			--End code

		commit tran

	end try
	begin catch
		--if a transaction was started, rollback
		if @@trancount > 0
		begin
			rollback tran
		end
			
		--log error in table
		exec dbo.p_DBA_LogError

		--raise error to front end
		declare @errProc nvarchar(126),
				@errLine int,
				@errMsg  nvarchar(max)
		select  @errProc = error_procedure(),
				@errLine = error_line(),
				@errMsg  = error_message()
		raiserror('Proc: %s - Line: %d - Error: %s', 12 ,1 ,@errProc, @errLine, @errMsg)
		return(-1)
	end catch

END




GO

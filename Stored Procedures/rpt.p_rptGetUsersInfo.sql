SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [rpt].[p_rptGetUsersInfo] 
AS
BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

	SET NOCOUNT ON;

	begin try

		
			
			
			--OPEN SYMMETRIC KEY SLAPSymKey
			--DECRYPTION BY CERTIFICATE SLAPCert	
			
			SELECT [UserID]
				  ,[UserType]
				  ,[FirstName]
				  ,[MiddleInitial]
				  ,[LastName]
				  ,[AKA]
				  ,[Title]
				  ,[Email]
				  ,[Password]
				  ,[SSNumber]
				  ,[SSNHashed]
				  ,[InstitutionID]
				  ,[MMSLoanID]
				  ,[UserStatus]
				  ,[PayArrangementFlag]
				  ,[PayArrangementAmt]
				  ,[DelayedPayStartDate]
				  ,[PayArrangementComment]
				  ,[UniqueIdentifier]
				  ,[UserActivatedDate]
				  ,[Remarks]
				  ,[ForgottenLinkExpiry]
				  ,[SendInvoiceByEmail]
				  ,[IsDeleted]
				  ,[DateInserted]
				  ,[DateUpdated]
				  ,[InsertedBy]
				  ,[UpdatedBy]
			  FROM [SLAP].[act].[UserInfo]
	

			--SELECT 0 ERRORCODE , 'Successful' ERRORMESSAGE		
			
		

	end try
	begin catch
		--if a transaction was started, rollback
		--if @@trancount > 0
		--begin
		--	rollback tran
		--end
			
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

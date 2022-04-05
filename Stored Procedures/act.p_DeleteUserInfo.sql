SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_DeleteUserInfo] 
		@Requestor VARCHAR(25),
		@UserID int ,
		@UpdatedBy varchar(50)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	delete one user
-- 02/25/2015 - sv add impersonation data output

/* test data

EXEC	[act].[p_DeleteUserInfo]
		@Requestor = N'test',
		@UserID = 0,
		@UpdatedBy = N'debug'

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
	
			-- An update to this user is to be done
			UPDATE UserInfo 
			SET 
				
				IsDeleted  = 'Y',	
				UpdatedBy = @UpdatedBy,
				DateUpdated = getdate()

			Where UserID = @UserID	

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
					,[InstitutionID]
					,[MMSLoanID]
					,[UserStatus]
					,[UniqueIdentifier]
					,[UserActivatedDate]
					,[Remarks]
					,[ForgottenLinkExpiry]
					,[IsDeleted]
					,[DateInserted]
					,[DateUpdated]
					,[InsertedBy]
					,[UpdatedBy] 
					,cd.CodeDescription AS  'UserStatusDescription'
					,cd.CodeDescriptionInternal as 'UserStatusDescriptionInternal'
 				    ,[SendInvoiceByEmail]
					,PayArrangementFlag
					,PayArrangementAmt
					,DelayedPayStartDate
					,PayArrangementComment
					,SchoolNotificationEmail
					,DoNotSendInvoiceFlag
					,DoNotSendInvoiceComment
					,0 'IsImpersonated'
					,'' 'ImpersonatedBy'
					,0 'OverrideRORestriction'
				FROM [act].[UserInfo] u
						LEFT OUTER JOIN  opr.CodeLookup AS cd ON u.UserStatus = cd.Code AND cd.FieldName = 'UserStatus' 

				WHERE UserID = @UserID

				SELECT 0 ERRORCODE, 'Successful...' ERRORMESSAGE
		
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

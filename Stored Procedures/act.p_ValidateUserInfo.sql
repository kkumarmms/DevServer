SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [act].[p_ValidateUserInfo] 
		@Requestor VARCHAR(25),
		@IncludeDeleted CHAR(1) = 'N',
		@FirstName varchar(50),
		@LastName varchar(50),
		@Email varchar(100),
		@SSNNumber varchar(100),
		@UniqueIdentifier  VARCHAR(50),
		@DateAttempt datetime = null
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	validate and return user info
-- 02/25/2015 - sv add impersonation data output

/* test data

EXEC	[act].[p_ValidateUserInfo]
		@Requestor = N'svatasoiu@yahoo.com',
		@IncludeDeleted = N'N',
		@FirstName = N'Sorin',
		@LastName = N'Student',
		@Email = N'svatasoiu@yahoo.com',
		@SSNNumber = N'111111111',
		@UniqueIdentifier = N'955BEC7A-862D-4C6F-8F5E-2E41EF037FE8',
		@DateAttempt = NULL
*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			
			-- Return record for the user
			SELECT u.UserID
					,u.UserType 
					,u.FirstName
					,u.MiddleInitial 
					,u.LastName
					,u.Email
					,u.UniqueIdentifier
					,u.Remarks
					,u.DateInserted
					,u.DateUpdated
					,u.IsDeleted
					,u.InsertedBy
					,u.UpdatedBy
					,u.InstitutionID
					,u.ForgottenLinkExpiry
					,u.UserStatus
					,cd.CodeDescription AS  'UserStatusDescription'
					,cd.CodeDescriptionInternal as 'UserStatusDescriptionInternal'
					,u.MMSLoanID
					,u.Title
					,u.AKA
					,u.SendInvoiceByEmail
					,u.PayArrangementFlag
					,u.PayArrangementAmt
					,u.DelayedPayStartDate
					,u.PayArrangementComment
					,isnull(u.SchoolNotificationEmail,'') 'SchoolNotificationEmail'
					,DoNotSendInvoiceFlag
					,DoNotSendInvoiceComment
					,0 'IsImpersonated'
					,'' 'ImpersonatedBy'
					,0 'OverrideRORestriction'
			FROM	act.UserInfo AS u 
							LEFT OUTER JOIN  opr.CodeLookup AS cd ON u.UserStatus = cd.Code AND cd.FieldName = 'UserStatus' 
			WHERE   LTRIM(RTRIM(UPPER(u.Email))) = LTRIM(RTRIM(UPPER(@Email)))
				and u.SSNHashed = dbo.HashData(@SSNNumber)
				and u.UniqueIdentifier = @UniqueIdentifier
				and	u.IsDeleted = CASE
						WHEN @IncludeDeleted = 'N' THEN 'N'
						ELSE u.IsDeleted    
					END
	
	

			SELECT 0 ERRORCODE , 'Successful' ERRORMESSAGE		
			
		
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
GRANT EXECUTE ON  [act].[p_ValidateUserInfo] TO [ExecSP]
GO

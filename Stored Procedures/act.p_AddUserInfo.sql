SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_AddUserInfo] 
		@Requestor VARCHAR(25),
		@UserType char(1) ,
		@FirstName varchar(50) ,
		@MiddleInitial varchar(10) = null,
		@LastName varchar(50) ,
		@Email varchar(100) ,
		@SSNumber varchar(100) = null,
		@InstitutionID smallint ,
		@UniqueIdentifier varchar(50) = null,
		@Remarks varchar(255) = null,
		@ForgottenLinkExpiry datetime2(7) = null,
		@IsDeleted char(1) = 'N',
		@InsertedBy varchar(50),
		@UserStatus int = 100,
		@MMSLoanID int = -1,
		@Title varchar(10) = null,
		@AKA varchar(50) = null,
		@SendInvoiceByEmail varchar(1) = 'P',
		@SchoolNotificationEmail varchar(100) = ''

AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	Add a new user
-- 02/25/2015 - sv add impersonation data output

/* test data

EXEC	[act].[p_AddUserInfo]
		@Requestor = N'test',
		@UserType = N'S',
		@FirstName = N'test',
		@MiddleInitial = N'x',
		@LastName = N'user',
		@Email = N'user@mms.org',
		@SSNumber = N'123121234',
		@InstitutionID = 38,
		@UniqueIdentifier = N'1234567890',
		@Remarks = N'good to go',
		@ForgottenLinkExpiry = NULL,
		@IsDeleted = N'N',
		@InsertedBy = N'debug',
		@UserStatus = 100,
		@MMSLoanID = 1,
		@Title = N'mr.',
		@AKA = N'aka',
		@SendInvoiceByEmail = N'P',
		@SchoolNotificationEmail = ''

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			DECLARE @UserIdentity int
			DECLARE @MemUniqID varchar(255)
			declare @SchoolName varchar(100)

			DECLARE @FullName varchar(255)
			declare @LoanAmount decimal(9,2)	
			
			OPEN SYMMETRIC KEY SLAPSymKey
				DECRYPTION BY CERTIFICATE SLAPCert	

			--select 'Insert new user'
			IF EXISTS 
			( 
				SELECT 
					[Email]
				FROM act.UserInfo ui 
				WHERE  
				(	LTRIM(RTRIM(UPPER(ui.Email))) = LTRIM(RTRIM(UPPER(@Email))) 
					OR ui.SSNHashed =  HASHBYTES('SHA2_512', @SSNumber)
				)
				AND ui.IsDeleted = 'N'
			)
			BEGIN
					SELECT [UserID]
						  ,[UserType]
						  ,[FirstName]
						  ,[MiddleInitial]
						  ,[LastName]
						  ,[AKA]
						  ,[Title]
						  ,[Email]
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
						,u.PayArrangementFlag
						,u.PayArrangementAmt
						,u.DelayedPayStartDate
						,u.PayArrangementComment
						,u.SchoolNotificationEmail
						,u.DoNotSendInvoiceFlag
						,u.DoNotSendInvoiceComment
						,0 'IsImpersonated'
						,'' 'ImpersonatedBy'
						,0 'OverrideRORestriction'
					FROM act.UserInfo u 
						LEFT OUTER JOIN  opr.CodeLookup AS cd ON u.UserStatus = cd.Code AND cd.FieldName = 'UserStatus' 
					WHERE  
					(	LTRIM(RTRIM(UPPER(u.Email))) = LTRIM(RTRIM(UPPER(@Email))) 
						OR  u.SSNHashed =  HASHBYTES('SHA2_512', @SSNumber)
					)
					AND u.IsDeleted = 'N'

					SELECT -100 ERRORCODE , 'Email address or SSN already exists.' ERRORMESSAGE
			END
			ELSE
			BEGIN

				-- newuid instead of @UniqueIdentifier inserted
				INSERT INTO act.UserInfo (
						[UserType]
						,[FirstName]
						,[MiddleInitial]
						,[LastName]
						,[AKA]
						,[Title]
						,[Email]
						,[SSNumber]
						,[SSNHashed]
						,[InstitutionID]
						,[UniqueIdentifier]
						,[Remarks]
						,[ForgottenLinkExpiry]
						,[UserStatus]
						,[IsDeleted]
						,[InsertedBy]
						,[DateInserted]
						,[MMSLoanID]
						,[SendInvoiceByEmail]
						,[SchoolNotificationEmail])
				(SELECT
						@UserType
						,@FirstName
						,@MiddleInitial
						,@LastName
						,@AKA
						,@Title
						,@Email
						,dbo.EncryptData(@SSNumber) 
						,dbo.HashData(@SSNumber)
						,@InstitutionID
						,newid()
						,@Remarks
						,@ForgottenLinkExpiry
						,@UserStatus
						,'N'
						,@InsertedBy
						,getdate()
						,@MMSLoanID
						,@SendInvoiceByEmail
						,@SchoolNotificationEmail)

				set @UserIdentity = SCOPE_IDENTITY()
--select SCOPE_IDENTITY() 'SCOPE_IDENTITY', @@IDENTITY 'IDENTITY'


				SELECT [UserID]
					  ,[UserType]
					  ,[FirstName]
					  ,[MiddleInitial]
					  ,[LastName]
					  ,[AKA]
					  ,[Title]
					  ,[Email]
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
				FROM act.UserInfo u 
						LEFT OUTER JOIN  opr.CodeLookup AS cd ON u.UserStatus = cd.Code AND cd.FieldName = 'UserStatus' 
				WHERE u.UserID = @UserIdentity

				SELECT 0 ERRORCODE, 'Successful...' ERRORMESSAGE
				IF (@UserStatus = 100 and @UserType = 'S') --new student
				BEGIN
				-- Add the application seed
					/*
					the officerId in the app will be updated later in the code from a call to app.p_FixOfficerID_Application
					*/

					set @LoanAmount = isnull((SELECT LoanAmount FROM opr.MMSLoans WHERE  (MMSLoanID = @MMSLoanID) ),0)
					set @SchoolName = isnull((SELECT InstitutionName FROM opr.Institution WHERE  InstitutionID = @InstitutionID),'')

					EXEC [app].[p_CreateApplication] @UserId=@UserIdentity ,
												 @OfficerId = 0,
												 @FirstName = @FirstName,
												 @LastName = @LastName,
												 @MiddleInitial = @MiddleInitial,
												 @MMSLoanID = @MMSLoanID,
												 @LoanAmt = @LoanAmount,
												 @MDDegreeFromSchool = @SchoolName,
												 @ApplStatus = 200 --seed application created

					-- Send email out
					SET @MemUniqID = newid() 
					SET @FullName = @FirstName + ' ' + @LastName
			    
					UPDATE UserInfo 
					SET UniqueIdentifier = @MemUniqID,
						ForgottenLinkExpiry = dateadd(mm,6,getdate())
					WHERE  LTRIM(RTRIM(UPPER(Email))) = LTRIM(RTRIM(UPPER(@Email)))  

					EXEC act.p_EmailIntialAccountSetUp @Email, @FullName, @MemUniqID
				END	

				IF (@UserStatus = 100 and @UserType = 'O') --new loan officer
				BEGIN
					--new loan officer, send email to create/reset password
					-- Send email out
					SET @MemUniqID = newid() 
					SET @FullName = @FirstName + ' ' + @LastName
					declare @ExpireDateTime datetime
					set @ExpireDateTime = dateadd(mm,6,getdate())
					declare @EmailSubject varchar(100)
					set @EmailSubject = 'MMS SLAP Account Setup Required'

					UPDATE UserInfo 
						SET UniqueIdentifier = @MemUniqID,
							ForgottenLinkExpiry = @ExpireDateTime
					WHERE  LTRIM(RTRIM(UPPER(Email))) = LTRIM(RTRIM(UPPER(@Email)))  

					exec [act].[p_EmailForgotPassword]	@Email, @FullName, @MemUniqID, @ExpireDateTime, @EmailSubject

				END
		    END  

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

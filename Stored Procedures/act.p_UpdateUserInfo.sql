SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_UpdateUserInfo] 
		@Requestor VARCHAR(25),
		@UserID int ,
		@UserType char(1) ,
		@FirstName varchar(50) ,
		@MiddleInitial varchar(10) = '',
		@LastName varchar(50) ,
		@Email varchar(100) ,
		@InstitutionID smallint ,
		@UniqueIdentifier varchar(50) ,
		@Remarks varchar(255) = null,
		@ForgottenLinkExpiry datetime2(7) = null,
		@IsDeleted char(1),
		@UpdatedBy varchar(50),
		@UserStatus int ,
		@MMSLoanID int ,
		@Title varchar(10) = null,
		@AKA varchar(50) = null,
		@SendInvoiceByEmail varchar(1) = 'P',
		@PayArrangementFlag bit,
		@PayArrangementAmt decimal,
		@DelayedPayStartDate date = null,
		@PayArrangementComment varchar(1000)='',
		@SchoolNotificationEmail varchar(100) = '',
		@DoNotSendInvoiceFlag bit,
		@DoNotSendInvoiceComment varchar(250)=''
	AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	update user info
-- 02/25/2015 - sv add impersonation data output

/* test data

EXEC	[act].[p_UpdateUserInfo]
		@Requestor = N'test',
		@UserID = 1,
		@UserType = N'S',
		@FirstName = N'test',
		@MiddleInitial = N'x',
		@LastName = N'test',
		@Email = N'test@mms.org',
		@InstitutionID = 38,
		@UniqueIdentifier = N'11111111111',
		@Remarks = N'xx',
		@IsDeleted = N'N',
		@UpdatedBy = N'test',
		@UserStatus = 100,
		@MMSLoanID = 1,
		@Title = N'mr',
		@AKA = N'aka',
		@SendInvoiceByEmail = N'P',
		@PayArrangementFlag = 0,
		@PayArrangementAmt = 100,
		@DelayedPayStartDate = NULL,
		@PayArrangementComment = NULL,
		@SchoolNotificationEmail  = '',
		@DoNotSendInvoiceFlag = 0,
		@DoNotSendInvoiceComment ='test'
*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			--Begin code
			DECLARE @UserIdentity int
			DECLARE @MemUniqID varchar(255)

			DECLARE @FullName varchar(255)
			DECLARE @EmailID varchar(50)
			DECLARE @sql VARCHAR(1000)		
			
			OPEN SYMMETRIC KEY SLAPSymKey
				DECRYPTION BY CERTIFICATE SLAPCert	

			-- An update to this user is to be done
			UPDATE UserInfo 
			SET 
				UserType = @UserType , 
				FirstName = @FirstName,	
				MiddleInitial= @MiddleInitial ,
				LastName= @LastName ,
				Email  = @Email,	
				InstitutionID= @InstitutionID,  
				Remarks  = @Remarks,	
				IsDeleted  = @IsDeleted,	
				ForgottenLinkExpiry  = @ForgottenLinkExpiry,	
				UniqueIdentifier = @UniqueIdentifier,
				UpdatedBy = @UpdatedBy,
				MMSLoanID = @MMSLoanID	,
				UserStatus = @UserStatus ,
				AKA = @AKA,
				Title = @Title,
				SendInvoiceByEmail = @SendInvoiceByEmail,
				PayArrangementFlag = @PayArrangementFlag,
				PayArrangementAmt = @PayArrangementAmt,
				DelayedPayStartDate = @DelayedPayStartDate,
				PayArrangementComment = @PayArrangementComment,
				SchoolNotificationEmail =@SchoolNotificationEmail,
				DoNotSendInvoiceFlag = @DoNotSendInvoiceFlag,
				DoNotSendInvoiceComment = @DoNotSendInvoiceComment ,
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
				FROM [act].[UserInfo] as u
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

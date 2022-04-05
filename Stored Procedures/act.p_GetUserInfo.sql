SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_GetUserInfo] 
		@Requestor VARCHAR(25),
		@IncludeDeleted CHAR(1),
		@UserId int,
		@UniqueIdentifier  VARCHAR(50),
		@Institution int,
		@FilterByUserType char(1) = '',
		@IsImpersonated bit = 0,
		@ImpersonatedBy varchar(50) = '',
		@OverrideRORestriction bit = 0
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	return user(s) based on filters 
-- 02/23/2015 sv add impersonation info
/* test data

EXEC	[act].[p_GetUserInfo]
		@Requestor = N'sorin',
		@IncludeDeleted = N'Y',
		@UserId = 0,
		@UniqueIdentifier = N'',
		@Institution = 0,
		@FilterByUserType = N'',
		@IsImpersonated = 1,
		@ImpersonatedBy = 'admin',
		@OverrideRORestriction = 0

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			--OPEN SYMMETRIC KEY SLAPSymKey
			--DECRYPTION BY CERTIFICATE SLAPCert	
			
			-- Return record for the user
			SELECT u.UserID
					,u.UserType 
					,u.FirstName
					,u.MiddleInitial 
					,u.LastName
					,u.AKA
					,u.Title
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
					,u.SendInvoiceByEmail
					,u.PayArrangementFlag
					,u.PayArrangementAmt
					,u.DelayedPayStartDate
					,u.PayArrangementComment
					,isnull(u.SchoolNotificationEmail,'') 'SchoolNotificationEmail'
					,u.DoNotSendInvoiceFlag
					,isnull(u.DoNotSendInvoiceComment,'') 'DoNotSendInvoiceComment'
					,@IsImpersonated 'IsImpersonated'
					,@ImpersonatedBy 'ImpersonatedBy'
					,@OverrideRORestriction 'OverrideRORestriction'
			FROM	act.UserInfo AS u 							
				LEFT OUTER JOIN  opr.CodeLookup AS cd ON u.UserStatus = cd.Code AND cd.FieldName = 'UserStatus' 

			WHERE     	
					u.UserID = CASE 
						WHEN @UserId > 0 THEN @UserId
						ELSE u.UserID
					END   
				AND     
					u.IsDeleted = CASE
						WHEN @IncludeDeleted = 'N' THEN 'N'
						ELSE u.IsDeleted    
					END
				AND	
					isnull(u.UniqueIdentifier,'') = case	
						when isnull(@UniqueIdentifier,'') <> '' then	 @UniqueIdentifier
						else isnull(u.UniqueIdentifier,'')
					end
				AND
						u.InstitutionID = CASE
						WHEN @Institution > 0 THEN @Institution
						ELSE u.InstitutionID
					END
				AND
						u.UserType = CASE
						WHEN isnull(@FilterByUserType,'') <> '' THEN @FilterByUserType
						ELSE u.UserType
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

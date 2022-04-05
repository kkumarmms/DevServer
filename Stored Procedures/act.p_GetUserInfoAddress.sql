SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_GetUserInfoAddress]
		@Requestor VARCHAR(25)='MMS',
		@IncludeDeleted CHAR(1)='N',
		@UserId int=0,
		@UniqueIdentifier  VARCHAR(50)='',
		@Institution int=0,
		@FilterByUserType char(1) = '',
		@FilterByAdrCode char(1) = '',
		@SearchValue varchar(50) = '',
		@SearchType varchar(50) = '',
		@MaxReturn int = 100
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	get user(s) and address info based on filters

/*test data

EXEC	[act].[p_GetUserInfoAddress]
		@Requestor = N'test',
		@IncludeDeleted = N'N',
		@UserId = 0,
		@UniqueIdentifier = NULL,
		@Institution = 0,
		@FilterByUserType = N'S',
		@FilterByAdrCode = N'S',
		@SearchValue = NULL,
		@SearchType = N'LastName',
		@MaxReturn = 100

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			declare @SearchValueLike varchar(50)
			set @SearchValueLike = isnull(@SearchValue,'') + '%'

			--Begin code
			OPEN SYMMETRIC KEY SLAPSymKey
			DECRYPTION BY CERTIFICATE SLAPCert	
			
			-- Return record for the user
			SELECT top (@MaxReturn )
					u.UserID
					,u.UserType 
					,u.FirstName
					,u.MiddleInitial 
					,u.LastName
					,u.AKA
					,u.Title
					,u.Email
					,'' SSNumber
					,'' Password
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
					,u.MMSLoanID
					,a.AddressID
					,a.AdrCode
					,a.AdrFlag
					,a.Address1
					,a.Address2
					,a.City
					,a.State
					,a.Zip
					,a.Country
					,a.Phone
					,a.PhoneCell
					,i.InstitutionName
                    ,cd.CodeDescription AS 'UserStatusDescription'
					,cd.CodeDescriptionInternal as 'UserStatusDescriptionInternal'
					,u.SendInvoiceByEmail
		FROM         act.UserInfo AS u 
				INNER JOIN   opr.Institution AS i ON u.InstitutionID = i.InstitutionID 
				LEFT OUTER JOIN  opr.CodeLookup AS cd ON u.UserStatus = cd.Code AND cd.FieldName = 'UserStatus' 
				LEFT OUTER JOIN  act.Address AS a ON u.UserID = a.UserID 
											AND a.AdrCode = @FilterByAdrCode AND a.AdrFlag = 0


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
					--ISNULL(UniqueIdentifier, ' ') = CASE	
					isnull(UniqueIdentifier,'')  = CASE	
						WHEN ISNULL(u.UniqueIdentifier, ' ') = ' '  THEN ''
						WHEN LTRIM(RTRIM(@UniqueIdentifier)) != '' THEN @UniqueIdentifier
						ELSE u.UniqueIdentifier
					END
				AND
						u.InstitutionID = CASE
						WHEN @Institution > 0 THEN @Institution
						ELSE u.InstitutionID
					END
				AND
						u.UserType = CASE
						WHEN @FilterByUserType <> '' THEN @FilterByUserType
						ELSE u.UserType

				END
				AND
						(
							@SearchType = '' or 
							(@SearchType = 'LastName' and u.LastName like @SearchValueLike)
										 or 
							(@SearchType = 'AKA' and u.AKA like @SearchValueLike)
										 or 
							(@SearchType = 'UserId' and ltrim(rtrim(CONVERT(varchar(12), u.UserID)))  like @SearchValueLike)
						)

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
GRANT EXECUTE ON  [act].[p_GetUserInfoAddress] TO [ExecSP]
GO

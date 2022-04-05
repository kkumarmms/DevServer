SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_AddAddress]
		@Requestor varchar(25) = ''
		,@UserID int
		,@AdrCode char(1)
		,@Address1 varchar(50)
		,@Address2 varchar(50) = null
		,@City varchar(50)
		,@State varchar(3)
		,@Zip varchar(10)
		,@Country varchar(50)
		,@Phone varchar(20)
		,@PhoneCell varchar(20) = null
		,@InsertedBy varchar(50) = null
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 04/01/2014
-- Description:	Add a new address for a user

/* test data

EXEC	[act].[p_AddAddress]
		@Requestor = N'test',
		@UserID = 1,
		@AdrCode = N'S',
		@Address1 = N'1 main st',
		@Address2 = N'apt 2',
		@City = N'waltham',
		@State = N'MA',
		@Zip = N'02121',
		@Country = N'US',
		@Phone = N'1231231234',
		@PhoneCell = N'1112223333',
		@InsertedBy = N'debug'

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			---- first we need to update AdrFlg to AddrFlag +1
			UPDATE act.Address
			SET AdrFlag = AdrFlag +1
				,UpdatedBy = SUSER_SNAME()
				,DateUpdated = getdate()
			WHERE 
				1=1 and
				UserID = @UserID and
				AdrCode = @AdrCode
			
			--Begin code
			--insert
			INSERT INTO act.Address
						(UserID
						,AdrCode
						,AdrFlag
						,Address1
						,Address2
						,City
						,State
						,Zip
						,Country
						,Phone
						,PhoneCell
						,DateInserted
						,IsDeleted
						,InsertedBy)
			SELECT
					@UserID 
					,@AdrCode 
					, 0 
					,@Address1 
					,@Address2
					,@City
					,@State 
					,@Zip 
					,@Country 
					,@Phone 
					,@PhoneCell 
					,getdate()
					,'N'
					,@InsertedBy

			select AddressID
					,UserID
					,AdrCode
					,AdrFlag
					,Address1
					,Address2
					,City
					,State
					,Zip
					,Country
					,Phone
					,PhoneCell
					,DateInserted
					,DateUpdated
					,IsDeleted
					,InsertedBy
					,UpdatedBy
			from act.Address
			where AddressID = @@IDENTITY

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

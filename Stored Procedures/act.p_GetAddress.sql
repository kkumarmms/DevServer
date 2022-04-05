SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [act].[p_GetAddress]
            @UserID int
           ,@AdrCode char(1)
           ,@AdrFlag tinyint = 0

as
/***
	Author: Mike Sherman
	Date:   2014-01-17
	Desc:  Returns either "Active" Address if no @AdrFlag parameter specified or All address history
***/

set nocount on

begin try

	if @AdrFlag =0
	BEGIN
		SELECT AddressID
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
		  FROM act.Address
		  WHERE 1=1 and
				UserID =	@UserID and 
				AdrCode = @AdrCode and
				AdrFlag = 0
		END

	ELSE
	BEGIN
		SELECT AddressID
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
		  FROM act.Address
		  WHERE 1=1 and
				UserID =	@UserID and 
				AdrCode = @AdrCode 
		  ORDER BY AdrFlag
		END

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
	Return (-1)
end catch



GO

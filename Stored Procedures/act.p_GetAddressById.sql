SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [act].[p_GetAddressById]
			@Requestor varchar(25),
            @AddressID int

as
/***
	Author: Sorin V.
	Date:   2014-01-17
	Desc:  Returns an address
***/

set nocount on

begin try

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
				@AddressID = AddressID

		  SELECT 0 ERRORCODE , 'Successful' ERRORMESSAGE		



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

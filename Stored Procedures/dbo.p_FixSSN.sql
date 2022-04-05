SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[p_FixSSN]
@userid int, @SSNumber char (11)
as
/***
	Author: Msherman
	Date:  2014-07-25 
	Desc:  Fix invalid SSN
***/

set nocount on

begin try
	/*
	declare @SSNumber char (11)
	declare @userid int = 2916
	set @SSNumber = 'xxx-xx-xxxx'
	*/
			OPEN SYMMETRIC KEY SLAPSymKey
				DECRYPTION BY CERTIFICATE SLAPCert	

	update act.UserInfo set 
			SSNumber =  dbo.EncryptData(@SSNumber) 
			,SSNHashed = dbo.HashData(@SSNumber)
			--,email = ''
	where UserId = @userid

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

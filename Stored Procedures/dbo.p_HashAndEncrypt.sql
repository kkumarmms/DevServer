SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[p_HashAndEncrypt]

as
/***
	Author: Msherman
	Date:   2014-05-01
	Desc:  Replace sensitive info on dev and qa
***/

set nocount on

begin try

if @@servername <> 'SQL12PROD1'
begin
			OPEN SYMMETRIC KEY SLAPSymKey
			DECRYPTION BY CERTIFICATE SLAPCert
	update act.UserInfo 
	set
	 [SSNumber] = [SLAP].dbo.EncryptData('123-12-'+ right('0000'+convert(varchar(4),UserID),4))
	,[SSNHashed] =[SLAP].dbo.HashData('123-12-'+ right('0000'+convert(varchar(4),UserID),4))
	
END


if @@servername = 'SQL12PROD1'
begin
			OPEN SYMMETRIC KEY SLAPSymKey
			DECRYPTION BY CERTIFICATE SLAPCert
	update act.UserInfo 
	set
	 [SSNumber] = [SLAP].dbo.EncryptData('123-12-'+ right('0000'+convert(varchar(4),UserID),4))
	,[SSNHashed] =[SLAP].dbo.HashData('123-12-'+ right('0000'+convert(varchar(4),UserID),4))
	--select * from act.UserInfo 
	where isnull(convert(varchar(1000),ssnumber),'')=''
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

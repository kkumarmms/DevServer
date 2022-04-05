SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[p_UpdateEmails_ForDEV_QA]

as
/***
	Author: svatasoiu
	Date:   2015-04-30
	Desc:   Update e-mails when copy db to DEV/QA to prevent accidental e-mail blast
***/

set nocount on

begin try
	--disable email accounts on dev
	update  act.UserInfo
	set Email = Email + '.1'
	WHERE     (Email <> '') 

	update  act.UserInfo
	set SchoolNotificationEmail = SchoolNotificationEmail + '.1'
	WHERE      Not( (SchoolNotificationEmail IS NULL)or SchoolNotificationEmail='')
	


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

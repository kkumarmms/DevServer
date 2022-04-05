SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[p_MergeUsers] --3386, 3238 --3377 , 3290--3379, 3292
	@MergeWhat int, 
	@mergeTo int
as
/***
	Author: msherman
	Date:   2014-07-25
	Desc:  Merge duplicate users

	2015-02-11 msh moved to production 
***/

set nocount on

begin try
/* - debugging
3377 to 3290
3390 to 3241 
	declare @MergeWhat int, @mergeTo int
	select @MergeWhat = 3390
	select @mergeTo = 3241

	select * from app.application where userid = @MergeWhat
	select * from act.UserInfo where userid = @MergeWhat
	select * from act.UserInfo where userid = @mergeTo
	select * from act.Address where userid = @MergeWhat
	select * from act.Address where userid = @mergeTo

*/
if exists (select UserID from fn.loans where userid = @MergeWhat) 
	raiserror('You Cannot Merge user that has active loan',12 ,1)
else
begin 
	begin Tran
		update [app].[Application] set UserID = @mergeTo where UserID = @MergeWhat

		if exists (select userid from [act].[Address] where UserID = @MergeWhat and AdrCode = 'S')
		begin
		update [act].[Address] set AdrFlag = AdrFlag + 1 where AdrCode = 'S' and UserID = @mergeTo
		update [act].[Address] set UserID = @mergeTo where AdrCode = 'S' and UserID = @MergeWhat   and AdrFlag = 0
		end

		if exists (select userid from [act].[Address] where UserID = @MergeWhat and AdrCode = 'P')
		begin
		update [act].[Address] set AdrFlag = AdrFlag + 1 where AdrCode = 'P' and UserID = @mergeTo
		update [act].[Address] set UserID = @mergeTo where AdrCode = 'P' and UserID = @MergeWhat   and AdrFlag = 0
		end
		--else
		--begin
		--update [act].[Address] set UserID = @mergeTo where UserID = @Mergeto and  AdrCode = 'S'  and AdrFlag = 0
		--end

		update MergeTo 
		set
			MergeTo.EMAIL = MergeWhat.EMAIL, 
			MergeTo.MMSLoanID = MergeWhat.MMSLoanID,
			MergeTo.LastName = MergeWhat.LastName,
			MergeTo.Password = MergeWhat.Password

		from		[act].[UserInfo] MergeTo 
		inner join	[act].[UserInfo] MergeWhat on MergeTo.UserID = @mergeTo and MergeWhat.UserID =@MergeWhat

		update [act].[UserInfo] 
		set
			EMAIL = EMAIL + '_Old' 
		where UserID = @MergeWhat 

		update [act].[UserInfo]  set IsDeleted = 'Y'  where UserID = @MergeWhat
	commit tran
end

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

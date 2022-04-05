SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [opr].[p_GetSiteNotificationForUser]
	-- Add the parameters for the stored procedure here
	@UserId int
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	get the site notification for this user
/*

EXEC	[opr].[p_GetSiteNotificationForUser]
		@UserId = 1589
*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			declare @Output varchar(2000)
			declare @Output1 varchar(1000)
			declare @Output2 varchar(1000)
			declare @Output3 varchar(1000)
			declare @Output4 varchar(1000)

			declare @hasPastDueAmount bit
			declare @hasLateFees bit
			declare @hasLoansPaidOff bit

			set @hasPastDueAmount = 0
			if (SELECT     ISNULL(SUM(LoanItemAmt), 0) AS Amount
				FROM         fn.LoanCurrState
				WHERE     (UserId = @UserId) AND (LoanItemID IN (2, 4)))>0
			Begin
				set @hasPastDueAmount = 1
			end


			set @hasLateFees = 0
			if (SELECT     ISNULL(SUM(LoanItemAmt), 0) AS Amount
				FROM         fn.LoanCurrState
				WHERE     (UserId = @UserId) AND (LoanItemID IN (5, 7)))>0
			Begin
				set @hasLateFees = 1
			end

			set @hasLoansPaidOff = 0
			if (SELECT     ISNULL(SUM(LoanItemAmt), 0) AS Amount
				FROM         fn.LoanCurrState
				WHERE     (UserId = @UserId) AND (LoanItemID IN (10)))<=0
			Begin
				set @hasLoansPaidOff = 1
			end



			-- get the 'All Students' messages => n.ShowOnlyIfCode = '1'
			SELECT @Output1 = COALESCE(@Output1 , '') + n.Message + '<br/>'
			FROM [opr].[SiteNotification] n
			WHERE n.ShowOnlyIfCode = '1'  --'All Students' --everybody
						and n.Active = 1
						and n.MessageStartDate <= getdate()
						and dateadd(day,1,isnull(MessageEndDate, getdate())) >= getdate()
			ORDER BY n.DisplayOrder
			
			-- get the 'Students with Past Due Amount' messages => n.ShowOnlyIfCode = '2'
			SELECT @Output2 = COALESCE(@Output2, '') + n.Message + '<br/>'
			FROM [opr].[SiteNotification] n
			WHERE n.ShowOnlyIfCode = '2'  --'Students with Past Due Amount'
						and n.Active = 1
						and n.MessageStartDate <= getdate()
						and dateadd(day,1,isnull(MessageEndDate, getdate())) >= getdate()
						and @hasPastDueAmount = 1
			ORDER BY n.DisplayOrder

			-- get the 'Students with Late Fees' messages => n.ShowOnlyIfCode = '3'
			SELECT @Output3 = COALESCE(@Output3 , '') + n.Message + '<br/>'
			FROM [opr].[SiteNotification] n
			WHERE n.ShowOnlyIfCode = '3'  --'Students with Late Fees'
						and n.Active = 1
						and n.MessageStartDate <= getdate()
						and dateadd(day,1,isnull(MessageEndDate, getdate())) >= getdate()
						and @hasLateFees =1 
			ORDER BY n.DisplayOrder

			-- get the 'Students with all loans paid off' messages => n.ShowOnlyIfCode = '4'
			SELECT @Output4 = COALESCE(@Output4 , '') + n.Message + '<br/>'
			FROM [opr].[SiteNotification] n
			WHERE n.ShowOnlyIfCode = '4'  --'Students with all loans paid off'
						and n.Active = 1
						and n.MessageStartDate <= getdate()
						and dateadd(day,1,isnull(MessageEndDate, getdate())) >= getdate()
						and @hasLoansPaidOff =1 
			ORDER BY n.DisplayOrder




			set @Output = isnull(@Output1,'') + isnull(@Output2,'') + isnull(@Output3,'') + isnull(@Output4,'')

			select @Output as 'SiteNotification'
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
GRANT EXECUTE ON  [opr].[p_GetSiteNotificationForUser] TO [ExecSP]
GO

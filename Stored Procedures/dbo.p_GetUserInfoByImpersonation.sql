SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[p_GetUserInfoByImpersonation]
	-- Add the parameters for the stored procedure here
	@ImpersonationGuid varchar(100)
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 02/23/2015
-- Description:	login a user by impersonation
/*

dbo.p_GetUserInfoByImpersonation @UniqueIdPar='3bf46044-c630-4e68-a943-eb12968a2250'

*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			declare	@Id int,
				@UserIdToImpersonate int,
				@ImpersonateBy  varchar(50),
				@ValidUntil datetime,
				@UniqueId uniqueidentifier,
				@Used bit,
				@OverrideRORestriction bit

			--get the impersonation record
			SELECT  @Id = Id, 
					@UserIdToImpersonate = UserIdToImpersonate, 
					@ImpersonateBy = ImpersonateBy, 
					@ValidUntil = ValidUntil, 
					@UniqueId = UniqueId, 
					@Used = Used, 
					@OverrideRORestriction = OverrideRORestriction
			FROM       dbo.UserImpersonationRequests
			WHERE     (UniqueId = @ImpersonationGuid)

			-- check if the request was already used
			if (@Used = 1)
			begin
				declare @errProc1 nvarchar(126),
						@errLine1 int,
						@errMsg1  nvarchar(max)
				set @errProc1 = ''
				set @errLine1 = 0
				set @errMsg1 = 'Invalid impersonation request - already used'

				raiserror('Invalid impersonation request - already used', 12 ,1 ,@errProc1, @errLine1, @errMsg1)
			end

			-- mark the record as used
			UPDATE       dbo.UserImpersonationRequests
			SET Used = 1,
				DateUpdated = getdate(),
				UpdatedBy = 'proc dbo.p_GetUserInfoByImpersonation'
			WHERE     (UniqueId = @ImpersonationGuid)
			
/*		
SELECT @Id
      ,@UserIdToImpersonate 'UserId'
      ,@ImpersonateBy
      ,@ValidUntil
      ,@UniqueId
      ,@Used
      ,@OverrideRORestriction
*/

			if (@id is null)
			begin
				--no user found
				--return a non existing user
				EXEC act.p_GetUserInfo  'Admin','N', -1,'', -1, 'X'
				--SELECT 1 ERRORCODE , 'No user found' ERRORMESSAGE	
			end
			else
			begin
				--user found
				--check impersonations conditions
				if @Used = 1 
				begin
					--this request was already used
					EXEC act.p_GetUserInfo  'Admin','N', -1,'', -1, 'X'
					--SELECT 1 ERRORCODE , 'Request already used' ERRORMESSAGE	
				end
				else
				begin
					--valid request; get the user
					EXEC act.p_GetUserInfo  'Admin','Y', @UserIdToImpersonate,'', 0, '',1,@ImpersonateBy,@OverrideRORestriction

				end
			end
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
GRANT EXECUTE ON  [dbo].[p_GetUserInfoByImpersonation] TO [ExecSP]
GO

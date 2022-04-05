SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_GetOpenApplicationsForInstitution]
	-- Add the parameters for the stored procedure here
		@InstitutionID int,
		@IncludeDeleted char(1) = 'N',
		@SearchValue varchar(50) = '',
		@SearchType varchar(50) = '',
		@MaxReturn int = 100
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	Get Open Applications For Institution
-- 07/17/2014 sv add 230,240,290 to app status that will show
-- 09.15.2015 sv add "AND ((@IncludeDeleted = 'Y') or (app.IsDeleted <> 'Y'))" to do not show deleted applications
/* test data

EXEC	[app].[p_GetOpenApplicationsForInstitution]
		@InstitutionID = 38,
		@IncludeDeleted = N'N',
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
			
			--Begin code
			declare @SearchValueLike varchar(50)
			set @SearchValueLike = @SearchValue + '%'

			SELECT  app.ApplicationID, 
					app.UserID, 
					app.ApplStatus, 
					app.LoanApprovedFlag, 
					app.LoanApprovedDate, 
					app.Uniqueidentifier, 
					app.DateInserted, 
					ISNULL(cd.CodeDescription, '')  AS 'ApplStatusDescription', 
					ISNULL(cd.CodeDescriptionInternal, '') AS 'ApplStatusDescriptionInternal', 
					u.FirstName, 
					u.LastName, 
					u.AKA, 
					u.Email, 
					u.InstitutionID, 
					i.InstitutionName,
					ISNULL(ln.LoanAmount, 0) AS 'LoanAmount', 
					ISNULL(ln.Description, '') AS 'LoanDescription'

			FROM      app.Application AS app INNER JOIN
                      act.UserInfo AS u ON app.UserID = u.UserID INNER JOIN
                      opr.Institution AS i ON u.InstitutionID = i.InstitutionID AND u.InstitutionID = i.InstitutionID INNER JOIN
                      opr.MMSLoans AS ln ON app.MMSLoanID = ln.MMSLoanID LEFT OUTER JOIN
                      opr.CodeLookup AS cd ON app.ApplStatus = cd.Code
			WHERE     (cd.CodeType = 'Application') 
					AND (cd.FieldName = 'ApplStatus')
					AND (u.InstitutionID = @InstitutionID)
					AND (app.ApplStatus in (200,210,220,230,240,290))
					AND ((@IncludeDeleted = 'Y') or (app.IsDeleted <> 'Y'))
					AND (isnull(app.LoanApprovedFlag,0) = 0)
					AND
						(
							@SearchType = '' or 
							(@SearchType = 'LastName' and u.LastName like @SearchValueLike)
										 or 
							(@SearchType = 'AKA' and u.AKA like @SearchValueLike)
										 or 
							(@SearchType = 'UserId' and ltrim(rtrim(CONVERT(varchar(12), u.UserID)))  like @SearchValueLike)
						)
			ORDER BY app.DateInserted DESC

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
GRANT EXECUTE ON  [app].[p_GetOpenApplicationsForInstitution] TO [ExecSP]
GO

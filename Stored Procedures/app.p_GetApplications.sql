SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_GetApplications]
	-- Add the parameters for the stored procedure here
		@IncludeDeleted char(1) = 'N',
		@SearchValue varchar(50) = '',
		@SearchType varchar(50) = '',
		@MaxReturn int = 100,
		@IncludeClosed char(1) = 'N'

AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	get applications based on filters
-- 07/10/2014 - sv - add ApplicationId filter
-- 02/24/2015 - sv - add include closed filter
/* test data


EXEC	[app].[p_GetApplications]
		@IncludeDeleted = N'N',
		@SearchValue = NULL,
		@SearchType = N'LastName',
		@MaxReturn = 100,
		@IncludeClosed = "Y"

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
			set @SearchValueLike = isnull(@SearchValue,'') + '%'
			set @SearchType = isnull(@SearchType,'')

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
--select *
			FROM         app.Application AS app INNER JOIN
                      act.UserInfo AS u ON app.UserID = u.UserID INNER JOIN
                      opr.Institution AS i ON u.InstitutionID = i.InstitutionID AND u.InstitutionID = i.InstitutionID INNER JOIN
                      opr.MMSLoans AS ln ON app.MMSLoanID = ln.MMSLoanID LEFT OUTER JOIN
                      opr.CodeLookup AS cd ON app.ApplStatus = cd.Code
			WHERE     (cd.CodeType = 'Application') 
					AND (cd.FieldName = 'ApplStatus')
					--AND (isnull(app.LoanApprovedFlag,0)= 0)
					AND (@IncludeClosed = 'Y' or isnull(app.LoanApprovedFlag,0)= 0)
					AND     
						app.IsDeleted = CASE
							WHEN @IncludeDeleted = 'N' THEN 'N'
							ELSE app.IsDeleted    
						END
					AND
						(
							@SearchType = '' or 
							(@SearchType = 'LastName' and u.LastName like @SearchValueLike)
										 or 
							(@SearchType = 'AKA' and u.AKA like @SearchValueLike)
										 or 
							(@SearchType = 'UserId' and ltrim(rtrim(CONVERT(varchar(12), u.UserID)))  like @SearchValueLike)
										 or 
							(@SearchType = 'ApplicationId' and ltrim(rtrim(CONVERT(varchar(12), app.ApplicationID)))  like @SearchValueLike)
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
GRANT EXECUTE ON  [app].[p_GetApplications] TO [ExecSP]
GO

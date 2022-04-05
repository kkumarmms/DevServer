SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--select * from UserInfo
--select * from LoanDetails
--select * from LoanStages
--select * from approvalstages
--exec p_MMS_SLAP_GetSchoolLoansSummary  'bk',1, 'Y', 'Y', 'Y'
--exec p_MMS_SLAP_GetSchoolLoansSummary  'bk',1, 'N', 'N', 'N'
--select * from LoanDetails
--select * from LoanDetails ld where ld.LoanDetailsID = ( select MAX(ld2.LoanDetailsID) from LoanDetails ld2 where ld2.UserID = ld.UserID and ld.LoanDetailsID = ld2.LoanDetailsID)

CREATE PROCEDURE [dbo].[p_MMS_SLAP_GetSchoolLoansSummary_old] 
@Requestor VARCHAR(25),
@InstitutionID integer,
@IncludeDeletedStudents CHAR(1),
@IncludeDeletedLoans CHAR(1),
@IncludeCompletedLoans CHAR(1)
AS

SET NOCOUNT ON

BEGIN

BEGIN TRY
BEGIN TRANSACTION
   DECLARE @dtDefault  datetime2
   SELECT @dtDefault = CONVERT(DATETIME2, '')
 
  /* At the point this stored proc was written, no payment flow in the database was available. So sending 0 and getdate in the select just so development can continue.
   * Mike Sherman has been assigned a resource to complete the database side of it for payments.
  */
    SELECT ui.UserID, ui.FirstName, ui.LastName, ls.ApprovalStageID, ld.LoanDetailsID, ld.LoanAmount, 0.00 AmountOwed, GETDATE() PaymentBeginDate
         FROM UserInfo ui, LoanDetails ld, LoanStages ls
         WHERE 
         ui.InstitutionID = @InstitutionID
         AND ui.IsDeleted = CASE
         WHEN @IncludeDeletedStudents = 'N' THEN 'N'
         ELSE ui.IsDeleted
         END
         AND ld.IsDeleted = CASE
         WHEN @IncludeDeletedLoans = 'N' THEN 'N'
         ELSE ld.IsDeleted         
         END
         AND ld.PaymentCompleteDate = CASE
         WHEN @IncludeCompletedLoans = 'N' THEN @dtDefault
         ELSE ld.PaymentCompleteDate     
         END
         AND ui.UserID = ld.UserID
         AND ld.LoanDetailsID = ls.LoanDetailsID
         AND ls.LoanStagesID = (SELECT MAX(ls2.LoanStagesID) FROM LoanStages ls2 WHERE ls.LoanDetailsID = ls2.LoanDetailsID)	 
 COMMIT TRANSACTION  
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	--log error in table
	
	exec dbo.p_DBA_LogError

	declare @errProc nvarchar(126),
			@errLine int,
			@errMsg  nvarchar(max)
	select  @errProc = 'dbo.p_MMS_SLAP_GetGetSchoolLoansSummary',
			@errLine = error_line(),
			@errMsg  = error_message()
	

	--raise error to front end
	raiserror('Proc: %s - Line: %d - Error: %s', 12 ,1 ,@errProc, @errLine, @errMsg)
	return(-1)
	--select  @errProc, @errLine, @errMsg ,'Job completed with errors - Notify developer'

END CATCH
END




GO

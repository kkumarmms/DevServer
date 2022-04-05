SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
DECLARE	@return_value int

EXEC	@return_value = [app].[p_CreateApplication]
	@UserID int,
	@OfficerId int ,
	@FirstName varchar(50) ,
	@MiddleInitial varchar(10) ,
	@LastName varchar(50) ,
	@AddressID int ,
	@ParentAddressID int ,
	@IsUSCitizen bit ,
	@IsMAResident bit ,
	@IsMMSStudent bit ,
	@MMSStudentID varchar(10) ,
	@HaveLoanCEF bit ,
	@MDDegreeFromSchool varchar(50) ,
	@MDDegreeDate varchar(10) ,
	@LocationAfterGrad varchar(100) ,
	@IsMarried bit ,
	@SpouseOccupation varchar(100) ,
	@Children tinyint ,
	@ChildsAge varchar(50) ,
	@IsSpouseApplForLoan bit ,
	@Comments varchar(5000) ,
	@ApplicantSignature varchar(50) ,
	@ApplicantSignedDate date ,
	@MMSLoanID tinyint,
	@LoanAmt decimal(9, 2) ,
	@OfficerSignature date ,
	@OfficerSignedDate date ,
	@MMSAmt decimal(9, 2) ,
	@MMSSignature varchar(50) ,
	@MMSSignedDate date ,
	@ApplStatus tinyint ,
	@LoanApprovedFlag bit ,
	@LoanApprovedDate date ,
	@Uniqueidentifier varchar(50) ,
	@IsDeleted nchar(10) ,
	@DateInserted datetime2(7) ,
	@DateUpdated datetime2(7) ,
	@InsertedBy varchar(50)  ,
	@UpdatedBy varchar(50) 

SELECT	'Return Value' = @return_value
*/

CREATE PROCEDURE [app].[p_CreateApplication] 
	--@ApplicationID int ,
	@UserID int,
	@OfficerId int ,
	@FirstName varchar(50) = null,
	@MiddleInitial varchar(10) = null,
	@LastName varchar(50) = null,
	@AddressID int = null,
	@ParentAddressID int = null,
	@IsUSCitizen bit = null,
	@IsMAResident bit = null,
	@IsMMSStudent bit = null,
	@MMSStudentID varchar(10) = null,
	@HaveLoanCEF bit = null,
	@MDDegreeFromSchool varchar(50) = null,
	@MDDegreeDate varchar(10) = null,
	@LocationAfterGrad varchar(100) = null,
	@IsMarried bit = null,
	@SpouseOccupation varchar(100) = null,
	@Children tinyint = null,
	@ChildsAge varchar(50) = null,
	@IsSpouseApplForLoan bit = null,
	@Comments varchar(5000) = null,
	@ApplicantSignature varchar(50) = null,
	@ApplicantSignedDate date = null,
	@MMSLoanID tinyint,
	@LoanAmt decimal(9, 2) = null,
	@OfficerSignature date = null,
	@OfficerSignedDate date = null,
	@MMSAmt decimal(9, 2) = null,
	@MMSSignature varchar(50) = null,
	@MMSSignedDate date = null,
	@ApplStatus tinyint = null,
	@LoanApprovedFlag bit = null,
	@LoanApprovedDate date = null,
	@Uniqueidentifier varchar(50) = null,
	@IsDeleted nchar(10) ='N' ,
	@DateInserted datetime2(7) = null ,
	@DateUpdated datetime2(7) = null ,
	@InsertedBy varchar(50) = null ,
	@UpdatedBy varchar(50) = null

AS
BEGIN
-- =============================================
-- Author:		Mike Sherman
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Set default values for optional parameters
	SET	@DateInserted = isnull(@DateInserted,getdate() ) 
	SET	@DateUpdated  = isnull(@DateUpdated,getdate() )
	SET	@InsertedBy =  isnull(@InsertedBy,suser_sname() )
	SET	@UpdatedBy = isnull(@UpdatedBy,suser_sname())
    -- Insert statements for procedure here
	begin try

		begin tran
			if @Uniqueidentifier is null
			begin
			 set @Uniqueidentifier = newid()
			end
				-- newuid instead of @UniqueIdentifier inserted
			INSERT INTO [app].[Application]
					(
					 [UserID]
					,[OfficerId]
					,[FirstName]
					,[MiddleInitial]
					,[LastName]
					,[AddressID]
					,[ParentAddressID]
					,[IsUSCitizen]
					,[IsMAResident]
					,[IsMMSStudent]
					,[MMSStudentID]
					,[HaveLoanCEF]
					,[MDDegreeFromSchool]
					,[MDDegreeDate]
					,[LocationAfterGrad]
					,[IsMarried]
					,[SpouseOccupation]
					,[Children]
					,[ChildsAge]
					,[IsSpouseApplForLoan]
					,[Comments]
					,[ApplicantSignature]
					,[ApplicantSignedDate]
					,[MMSLoanID]
					,[LoanAmt]
					,[OfficerSignature]
					,[OfficerSignedDate]
					,[MMSAmt]
					,[MMSSignature]
					,[MMSSignedDate]
					,[ApplStatus]
					,[LoanApprovedFlag]
					,[LoanApprovedDate]
					,[Uniqueidentifier]
					,[IsDeleted]
					,[DateInserted]
					,[DateUpdated]
					,[InsertedBy]
					,[UpdatedBy]
					)
			SELECT
					@UserID ,
					@OfficerId,
					@FirstName,
					@MiddleInitial ,
					@LastName ,
					@AddressID  ,
					@ParentAddressID  ,
					@IsUSCitizen  ,
					@IsMAResident  ,
					@IsMMSStudent  ,
					@MMSStudentID  ,
					@HaveLoanCEF  ,
					@MDDegreeFromSchool ,
					@MDDegreeDate ,
					@LocationAfterGrad  ,
					@IsMarried  ,
					@SpouseOccupation ,
					@Children  ,
					@ChildsAge ,
					@IsSpouseApplForLoan  ,
					@Comments  ,
					@ApplicantSignature ,
					@ApplicantSignedDate ,
					@MMSLoanID,
					@LoanAmt  ,
					@OfficerSignature  ,
					@OfficerSignedDate  ,
					@MMSAmt  ,
					@MMSSignature ,
					@MMSSignedDate  ,
					@ApplStatus  ,
					@LoanApprovedFlag  ,
					@LoanApprovedDate  ,
					@Uniqueidentifier ,
					@IsDeleted ,
					@DateInserted  ,
					@DateUpdated  ,
					@InsertedBy  ,
					@UpdatedBy


			SELECT 0 ERRORCODE, 'Successful...' ERRORMESSAGE
	  		
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

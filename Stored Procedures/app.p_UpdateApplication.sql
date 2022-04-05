SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_UpdateApplication]
	-- Add the parameters for the stored procedure here
	@ApplicationID  int  ,
	@UserID  int  ,
	@OfficerId  int  ,
	@FirstName  varchar(50) ,
	@MiddleInitial  varchar(10) = '',
	@LastName  varchar(50) ,
	@AddressID  int = null,
	@ParentAddressID  int = null,
	@IsUSCitizen  bit = null,
	@IsMAResident  bit  = null,
	@IsMMSStudent  bit = null,
	@MMSStudentID  varchar(10)  = '',
	@HaveLoanCEF  bit  = null,
	@MDDegreeFromSchool  varchar(50)  = '',
	@MDDegreeDate  varchar(10)  = '',
	@LocationAfterGrad  varchar(100)  = '',
	@IsMarried  bit  = null,
	@SpouseOccupation  varchar(100)  = '',
	@Children  tinyint  = null,
	@ChildsAge  varchar(50)  = '',
	@IsSpouseApplForLoan  bit  = null,
	@Comments  varchar(5000)  = '',
	@ApplicantSignature  varchar(50)  = '',
	@ApplicantSignedDate  date  = null,
	@MMSLoanID  tinyint  ,
	@LoanAmt  decimal(9, 2) ,
	@OfficerSignature  varchar(50)  = null,
	@OfficerSignedDate  date  = null,
	@MMSAmt  decimal(9, 2)  = null,
	@MMSSignature  varchar(50)  = '',
	@MMSSignedDate  date  = null,
	@ApplStatus  int ,
	@LoanApprovedFlag  bit  = null,
	@LoanApprovedDate  date  = null,
	@Uniqueidentifier  varchar(50) ,
	@IsDeleted  char(1)  = null,
	@UpdatedBy  varchar(50)  ,
	@LockedForStudent  bit ,
	@LockedForOfficer  bit ,
	@LockedForAdmin  bit 

AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	update application data
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			UPDATE [app].[Application]
			   SET [UserID] = @UserID,
				  [OfficerId] = @OfficerId, 
				  [FirstName] = @FirstName,
				  [MiddleInitial] = @MiddleInitial,
				  [LastName] = @LastName, 
				  [AddressID] = @AddressID, 
				  [ParentAddressID] = @ParentAddressID, 
				  [IsUSCitizen] = @IsUSCitizen, 
				  [IsMAResident] = @IsMAResident, 
				  [IsMMSStudent] = @IsMMSStudent, 
				  [MMSStudentID] = @MMSStudentID, 
				  [HaveLoanCEF] = @HaveLoanCEF, 
				  [MDDegreeFromSchool] = @MDDegreeFromSchool, 
				  [MDDegreeDate] = @MDDegreeDate, 
				  [LocationAfterGrad] = @LocationAfterGrad, 
				  [IsMarried] = @IsMarried, 
				  [SpouseOccupation] = @SpouseOccupation, 
				  [Children] = @Children,
				  [ChildsAge] = @ChildsAge, 
				  [IsSpouseApplForLoan] = @IsSpouseApplForLoan, 
				  [Comments] = @Comments, 
				  [ApplicantSignature] = @ApplicantSignature, 
				  [ApplicantSignedDate] = @ApplicantSignedDate, 
				  [MMSLoanID] = @MMSLoanID, 
				  [LoanAmt] = @LoanAmt, 
				  [OfficerSignature] = @OfficerSignature, 
				  [OfficerSignedDate] = @OfficerSignedDate, 
				  [MMSAmt] = @MMSAmt, 
				  [MMSSignature] = @MMSSignature, 
				  [MMSSignedDate] = @MMSSignedDate, 
				  [ApplStatus] = @ApplStatus, 
				  [LoanApprovedFlag] = @LoanApprovedFlag, 
				  [LoanApprovedDate] = @LoanApprovedDate, 
				  [Uniqueidentifier] = @Uniqueidentifier, 
				  [IsDeleted] = @IsDeleted, 
				  [DateUpdated] =getdate(), 
				  [UpdatedBy] = @UpdatedBy,
				  [LockedForStudent] =	@LockedForStudent  ,
				  [LockedForOfficer] = @LockedForOfficer  ,
				  [LockedForAdmin] = @LockedForAdmin   
			 WHERE ApplicationID = @ApplicationID	
			
			SELECT [ApplicationID]
			  ,[UserID]
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
			  ,[LockedForStudent]   
			  ,[LockedForOfficer]   
			  ,[LockedForAdmin]  		  
		  FROM [app].[Application]
		  WHERE ApplicationID = @ApplicationID


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
GRANT EXECUTE ON  [app].[p_UpdateApplication] TO [ExecSP]
GO

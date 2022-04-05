SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_AddInstitution]
			@Requestor VARCHAR(25) = 'MMSAdmin',
			@InstitutionName varchar(100) ,
			@Address1 varchar(100) ,
			@Address2 varchar(100) =null,
			@City varchar(50) ,
			@State char(2) ,
			@Zip varchar(10) ,
			@Phone varchar(20) ,
			@Email varchar(50) ,
			@Website varchar(100) ,
			@IsDeleted char(1) ,
			@InsertedBy varchar(50) 
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			
			--Begin code
			--new institution
			IF NOT EXISTS (
				SELECT Inst.InstitutionName 
				FROM opr.Institution Inst 
				WHERE LTRIM(RTRIM(UPPER(Inst.InstitutionName))) = LTRIM(RTRIM(UPPER(@InstitutionName)))
					--AND Inst.IsDeleted = 'N'
			)
			BEGIN
				BEGIN TRY
				INSERT INTO opr.Institution (InstitutionName,
										Address1,
										Address2,
										City,
										State,
										Zip,
										Phone,
										Email,
										Website,
										DateInserted,
										DateUpdated,
										IsDeleted,
										InsertedBy)
						VALUES (
								@InstitutionName  ,
								@Address1  ,
								@Address2 ,
								@City  ,
								@State  ,
								@Zip  ,
								@Phone ,
								@Email  ,
								@Website  ,
								GETDATE()   ,
								GETDATE()   ,
								'N'   ,
								@InsertedBy 
						)

		   
					SELECT TOP 1 InstitutionID,
								InstitutionName,
								Address1,
								Address2,
								City,
								State,
								Zip,
								Phone,
								Email,
								Website,
								DateInserted,
								DateUpdated,
								IsDeleted,
								InsertedBy,
								UpdatedBy 
					FROM opr.Institution Inst
					WHERE LTRIM(RTRIM(UPPER(Inst.InstitutionName))) = LTRIM(RTRIM(UPPER(@InstitutionName)))
						AND Inst.IsDeleted = 'N'
					SELECT 0 ERRORCODE, 'Successful.' ERRORMESSAGE
				END TRY
				BEGIN CATCH
				SELECT 	0 'InstitutionID'  ,
						@InstitutionName 'InstitutionName' ,
						@Address1 'Address1' ,
						@Address2 'Address2',
						@City 'City' ,
						@State 'State' ,
						@Zip 'Zip' ,
						@Phone 'Phone',
						@Email  'Email',
						@Website 'Website' ,
						getdate() 'DateInserted',
						getdate() 'DateUpdated',
						@IsDeleted 'IsDeleted' ,
						@InsertedBy 'InsertedBy',
						'' 'UpdatedBy'
						SELECT -100 ERRORCODE, ERROR_MESSAGE() ERRORMESSAGE
				END CATCH
			END
			ELSE
			BEGIN
				SELECT 	Inst.InstitutionID  ,
						Inst.InstitutionName  ,
						Inst.Address1 ,
						Inst.Address2 ,
						Inst.City ,
						Inst.State  ,
						Inst.Zip  ,
						Inst.Phone ,
						Inst.Email  ,
						Inst.Website  ,
						Inst.DateInserted,
						Inst.DateUpdated,
						Inst.IsDeleted ,
						Inst.InsertedBy,
						Inst.UpdatedBy

				FROM opr.Institution Inst 
				WHERE LTRIM(RTRIM(UPPER(Inst.InstitutionName))) = LTRIM(RTRIM(UPPER(@InstitutionName)))

				SELECT -200 ERRORCODE, 'Institution already exists. Try another name.' ERRORMESSAGE
			END
		
		
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

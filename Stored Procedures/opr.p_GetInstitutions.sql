SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [opr].[p_GetInstitutions]
	@Requestor VARCHAR(25),
	@IncludeDeleted CHAR(1),
	@InstitutionID int = 0
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
			if (@InstitutionID = 0)
			begin
				-- get all
				SELECT Inst.InstitutionID, 
						Inst.InstitutionName,
						Inst.Address1,
						Inst.Address2,
						Inst.City,
						Inst.State,
						Inst.Zip,
						Inst.Phone,
						Inst.Email,
						Inst.Website,
						Inst.DateInserted,
						Inst.DateUpdated,
						Inst.IsDeleted,
						Inst.InsertedBy,
						Inst.UpdatedBy 
				FROM Institution Inst
				WHERE 
					@IncludeDeleted = 'Y' or Inst.IsDeleted = 'N'
				ORDER BY Inst.InstitutionName

			end
			else
			begin
				-- get selected
			 IF EXISTS (
				SELECT Inst.InstitutionID 
				FROM Institution Inst 
				WHERE Inst.InstitutionID = @InstitutionID
					AND (@IncludeDeleted = 'Y' or Inst.IsDeleted = 'N')

				--UNION SELECT 1 FROM @dtInstitution dtI WHERE dtI.InstitutionID = 0
			  )
			  BEGIN
				SELECT Inst.InstitutionID, 
						Inst.InstitutionName,
						Inst.Address1,
						Inst.Address2,
						Inst.City,
						Inst.State,
						Inst.Zip,
						Inst.Phone,
						Inst.Email,
						Inst.Website,
						Inst.DateInserted,
						Inst.DateUpdated,
						Inst.IsDeleted,
						Inst.InsertedBy,
						Inst.UpdatedBy 
				FROM Institution Inst
				WHERE 
				  Inst.InstitutionID = @InstitutionID
				  AND (@IncludeDeleted = 'Y' or Inst.IsDeleted = 'N')
 		  
				  SELECT 0 ERRORCODE, 'Successful.' ERRORMESSAGE
			END
			ELSE
			BEGIN
					SELECT @InstitutionID as 'InstitutionID', 
						'' as'InstitutionName',
						'' as'Address1',
						'' as'Address2',
						'' as'City',
						'' as'State',
						'' as'Zip',
						'' as'Phone',
						'' as'Email',
						'' as'Website',
						getdate() as'DateInserted',
						getdate() as'DateUpdated',
						'' as'IsDeleted',
						'' as'InsertedBy',
						'' as'UpdatedBy' 

				SELECT -200 ERRORCODE, 'No such InstitutionID exists.' ERRORMESSAGE
			END		
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

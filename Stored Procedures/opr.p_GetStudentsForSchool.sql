SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [opr].[p_GetStudentsForSchool] --@InstitutionID=38,'Y'
	-- Add the parameters for the stored procedure here
	@InstitutionID int,
	@IncludeDeleted char(1) ='N',
	@SearchValue varchar(50) = '',
	@SearchType varchar(50) = '',
	@MaxReturn int = 500
AS
BEGIN
-- =============================================
/*
-- Author:		Sorin Vatasoiu
-- Create date: <Create Date,,>
-- Description:	<Description,,>

2014-05-21 msh need to filter to show students who got loans in previous year ONLY
2014-07-17 sv change filter to show students also current students
2015-07-27 msh need to show all new applications. Need one line per user. Filter on application date instead of loanApprovedDate
2015-11-01 msh/Sorin added students from exception list.
*/
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET @MaxReturn = 500  -- OVERWRITE WHATEVER PASSED FROM FRONTEND MSH 2015-07-27
	-- get start and end dates to filter on LoanApprovedDate. need students from previous year only
	declare @startDate date, @EndDate date

	select @startDate = 
			case
				when month(getdate()) >=5 and month(getdate()) <= 12 
				then convert(date, '5/1/' + convert(char(4),year(getdate()) -1))
				when month(getdate()) >=1 and month(getdate()) <= 4 
				then convert(date, '5/1/' + convert(char(4),year(getdate()) -2))
			end

	select @EndDate = 
			case
				when month(getdate()) >=5 and month(getdate()) <= 12 
				then convert(date, '4/30/' + convert(char(4),year(getdate())))
				when month(getdate()) >=1 and month(getdate()) <= 4 
				then convert(date, '4/30/' + convert(char(4),year(getdate()) -1))
			end
    -- Insert statements for procedure here
	begin try

		begin tran
			
			declare @SearchValueLike varchar(50)
			set @SearchValueLike = @SearchValue + '%'

			--Begin code
	;with CTE as
	(
			SELECT  distinct top (@MaxReturn )
			ROW_NUMBER() OVER (PARTITION BY usr.userid order by app.dateinserted desc) as seq,
					usr.UserID, 
					usr.FirstName, 
					usr.MiddleInitial, 
					usr.LastName, 
					usr.Email, 
					usr.MMSLoanID, 
					usr.UserStatus, 
					sts_u.CodeDescription as 'UserStatusDescription',
					usr.InstitutionID, 
					adr.Phone, 
					adr.PhoneCell, 
					app.MDDegreeDate,
					app.ApplStatus,
					sts_a.CodeDescription as 'ApplicationStatusDescription',
					sts_l.Code as 'LoanStatus',
					sts_l.CodeDescription as 'LoanStatusDescription',
					avl.LoansAvail as 'AvailableLoans',
					amt.LoanAmt as 'AmountOwed',
					'1/1/1900' as 'PaymentBeginDate'

			FROM				act.UserInfo usr 
					LEFT JOIN    app.Application app	ON usr.UserID = app.UserID 
					LEFT  JOIN	  act.Address  adr		ON usr.UserID = adr.UserID 
														AND adr.AdrCode = 'S' 
														AND adr.AdrFlag = 0
					LEFT  JOIN   [fn].[Loans] ln		ON  usr.UserID = ln.UserID 
					LEFT  JOIN   [opr].[CodeLookup] sts_u on usr.UserStatus = sts_u.Code 
														and sts_u.FieldName = 'UserStatus'
					LEFT  JOIN   [opr].[CodeLookup] sts_a on app.ApplStatus = sts_a.Code 
														and sts_a.FieldName = 'ApplStatus'    
					LEFT  JOIN   [opr].[CodeLookup] sts_l on usr.UserStatus = sts_l.Code 
														and sts_l.FieldName = 'LoanStatus'                                                                 
					outer apply  fn.f_GetTotalAmtBorrowed  (ln.LoanID) amt
					outer apply  fn.f_GetAvailLoans  (usr.UserID) avl
			WHERE			(usr.UserType = 'S') 
						AND usr.InstitutionID = @InstitutionID
						AND (usr.IsDeleted = 'N' or @IncludeDeleted = 'Y')
						AND
								(
									@SearchType = '' or 
									(@SearchType = 'LastName' and usr.LastName like @SearchValueLike)
												 or 
									(@SearchType = 'AKA' and usr.AKA like @SearchValueLike)
												 or 
									(@SearchType = 'UserId' and ltrim(rtrim(CONVERT(varchar(12), usr.UserID)))  like @SearchValueLike)
								)
						--AND ln.LoanApprovedDate between @startDate and getdate() --@EndDate
						AND app.DateInserted between @startDate and getdate() --@EndDate
				
			Order by usr.LastName

--- add exceptions 2015-11-01
			UNION
			SELECT  distinct top (@MaxReturn )
			ROW_NUMBER() OVER (PARTITION BY usr.userid order by app.dateinserted desc) as seq,
					usr.UserID, 
					usr.FirstName, 
					usr.MiddleInitial, 
					usr.LastName, 
					usr.Email, 
					usr.MMSLoanID, 
					usr.UserStatus, 
					sts_u.CodeDescription as 'UserStatusDescription',
					usr.InstitutionID, 
					adr.Phone, 
					adr.PhoneCell, 
					app.MDDegreeDate,
					app.ApplStatus,
					sts_a.CodeDescription as 'ApplicationStatusDescription',
					sts_l.Code as 'LoanStatus',
					sts_l.CodeDescription as 'LoanStatusDescription',
					avl.LoansAvail as 'AvailableLoans',
					amt.LoanAmt as 'AmountOwed',
					'1/1/1900' as 'PaymentBeginDate'

			FROM				act.UserInfo usr
					INNER JOIN  [act].[UserEligibilityException] ex on usr.UserID = ex.UserId
													and @InstitutionID = ex.InstitutionID
													and ex.Active = 1
													and ex.StartDate <= getdate()
													and ex.EndDate >= getdate() 
					LEFT JOIN    app.Application app	ON usr.UserID = app.UserID 
					LEFT  JOIN	  act.Address  adr		ON usr.UserID = adr.UserID 
														AND adr.AdrCode = 'S' 
														AND adr.AdrFlag = 0
					LEFT  JOIN   [fn].[Loans] ln		ON  usr.UserID = ln.UserID 
					LEFT  JOIN   [opr].[CodeLookup] sts_u on usr.UserStatus = sts_u.Code 
														and sts_u.FieldName = 'UserStatus'
					LEFT  JOIN   [opr].[CodeLookup] sts_a on app.ApplStatus = sts_a.Code 
														and sts_a.FieldName = 'ApplStatus'    
					LEFT  JOIN   [opr].[CodeLookup] sts_l on usr.UserStatus = sts_l.Code 
														and sts_l.FieldName = 'LoanStatus'                                                                 
					outer apply  fn.f_GetTotalAmtBorrowed  (ln.LoanID) amt
					outer apply  fn.f_GetAvailLoans  (usr.UserID) avl
			WHERE			(usr.UserType = 'S') 
						AND usr.InstitutionID = @InstitutionID
						AND (usr.IsDeleted = 'N' or @IncludeDeleted = 'Y')

				
			Order by usr.LastName



	)





	select * from CTE
	where seq =1
	--Order by app.DateInserted desc
			
		
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

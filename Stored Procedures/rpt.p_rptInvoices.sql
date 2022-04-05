SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--exec rpt.[p_rptInvoices] 

CREATE PROCEDURE [rpt].[p_rptInvoices] 

AS

BEGIN
-- =============================================
-- Author:		Andre Barber
-- Create date: '3/24/2014'
-- Description:	Invoices Report for Student Loan System
-- Modified 06052013 added new payarrangement fields
--mod 20150306 exclude electronic invoices from been printed
-- =============================================

	SET NOCOUNT ON;

	begin try

			select i.UserID as Acct
				, rtrim(i.FirstName) + ' '  + rtrim(i.LastName) + ', M.D.' as 'Name'
				,rtrim(isnull(i.Address1,'')) as 'Addr1'
				,rtrim(isnull(i.Address2,'')) as 'Addr2'
				,rtrim(i.City) + ', ' + rtrim(i.State) + ' ' + rtrim(i.zip)  as 'Addr3'
				,'Dr. ' + rtrim(i.LastName) as 'Salutation'
				,i.InstitutionName as 'School' 
				,'Date Of Loan1'=CASE isdate(i.LoanApprovedDate) when 1 then CONVERT(varchar(10),i.LoanApprovedDate,101) else '' end
				,'Date Of Loan2'=CASE isdate(i.Loan2ApprovedDate) when 1 then CONVERT(varchar(10),i.Loan2ApprovedDate,101) else '' end
				,'Principal_Balance' = i.Balance
				,'Overdue' = isnull(i.PrincipalOverdue,0.00) + isnull(i.InterestOverdue,0.00)
				,'Current_Principal_Due' = i.PrincipalDue
				,'Current_Interest_Due' = i.InterestDue				
				,'Late_Fee' = i.Latefee				
				,'Total Due'=	i.TotalDue	
				,i.ReturnedCheckFee
				,'Pay_ArrangementFlag' = CASE ISNULL(i.PayArrangementFlag,0) when 0 then 'F' else 'T' end
				,'Pay_Arrangement' = isnull(i.PayArrangementAmt,0.00)
				,'Delayed_StartDate' =  CASE isnull(i.DelayedPayStartDate,'') when '' then '' else CONVERT(varchar(10),i.DelayedPayStartDate,101) end
				,i.PayArrangementComment
				--select *
			from			fn.Invoices i 
				INNER JOIN	act.UserInfo u ON u.UserID = i.UserID
					
			WHERE i.InvoiceCurrentFlag = 0 
					AND u.SendInvoiceByEmail <> 'E'
			order by i.LastName,i.FirstName


	end try
	begin catch
				
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
	
	end catch

END


GO

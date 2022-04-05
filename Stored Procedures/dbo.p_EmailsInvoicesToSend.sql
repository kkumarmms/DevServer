SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[p_EmailsInvoicesToSend]
as
/***
	Author: Msherman 
	Date:   2014/04/02
	Desc:  builds invoice e-mails and populates mms_Email table to create a queue for e-mail blast
***/

set nocount on
begin try

declare 
@InvoiceID int,
@Address1 varchar(50),
@Address2 varchar(50),
@FirstName varchar(50),
@LastName varchar(50),
@City varchar(50),
@State varchar(3),
@Zip varchar(10),
@Title varchar(10), --u.title
@NextDueDate date,
@NextOverDueDate date,
@LoanApprovedDate datetime,
@Loan2ApprovedDate datetime,
@PrincipalBalance decimal (9,2),
@PrincipalDue decimal (9,2),
@PrincipalOverDue decimal (9,2),
@InterestDue decimal (9,2),
@InterestOverDue decimal (9,2),
@TotalDue decimal (9,2),
@CurrDate date,
@EndOfCurrMonth date,
@Profile_Name Varchar(50),
@recipients varchar(8000),
@Copy_Recipients varchar(8000),
@BCC_Recipients varchar(8000),
@Subject  varchar(255),
@Body  varchar(max),
@Body_Format char (4) ='HTML'

select 
	@Profile_Name = 'CEFUND',
	@NextDueDate = '6/30/2014', -- need logic from p_GetPaymentSchedule
	@NextOverDueDate = '6/30/2014', -- need logic from p_GetPaymentSchedule
	@Recipients = 'svatasoiu@mms.org',
	@Copy_Recipients = 'msherman@mms.org',
	@Subject = 'Test Invoice',
	@CurrDate = getdate(),
	@EndOfCurrMonth =   DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+1,0)),
	@NextDueDate = '06/30/' + 
		convert(Char(4), 
				case 
					when datepart(Month,getdate()) >=5 
					then datepart(Year,getdate())
					else datepart(Year,(dateadd( Year,-1,getdate())))
					end

				)  -- all invoices should have principal and interest due dates 6/30/<Year of the beginning of the billing cycle>
  --*****************************************
  -- PROCESS REGULAR INVOICES via EMAILS
  --*****************************************



 INSERT  [dbo].[mms_Email]
      ([Profile_Name]
      ,[recipients]
      ,[Copy_Recipients]
      ,[BCC_Recipients]
      ,[Subject]
      ,[Body_Format]
      ,[Body]

      --,[Attachments]
      )


 SELECT 
		[Profile_Name] =		@Profile_Name
		,[recipients] =			u.Email
		,[Copy_Recipients] =	@Copy_Recipients
		,[BCC_Recipients] =		@BCC_Recipients
		,[Subject] =			@Subject --'Regular invoice'
		,[Body_Format] =		@Body_Format
		,[Body] =				


--declare @CurrDate datetime = getdate() select
				replace (replace(replace(replace
				(replace(replace(replace(replace
				(replace (replace(replace(replace
				(replace (replace(replace(replace
				(replace (replace(replace(replace
				(replace(replace(replace(replace
				(replace(replace(replace(replace
				(t.EmailBody,
				'???FirstName???',	isnull(u.FirstName,'')),
				'???LastName???',	isnull(u.LastName,'')),
				'???Title???',		isnull(u.Title,'')),
				'???Address1???',	isnull(a.Address1,'')),
				'???Address2???',	isnull(a.Address2,'')),
				'???City???',		isnull(a.City,'')),
				'???State???',		isnull(a.State,'')),
				'???Zip???',		isnull(a.Zip,'')),
				'???School???',		isnull(inst.InstitutionName,'')),
				'???LoanApprovedDate???',			isnull(convert(Varchar(10),i.LoanApprovedDate,101),'')),
				'???Loan2ApprovedDate???',			isnull(convert(Varchar(10),i.Loan2ApprovedDate,101),'')),
				'???PrincipalBalance???',			isnull(i.Balance,'')),
				'???PrincipalDueAmt???',			isnull(i.PrincipalDue,'')),
				'???PrincipalOverDue???',			isnull(i.PrincipalOverDue,'')),
				'???InterestDueAmt???',				isnull(i.InterestDue,'')),
				'???InterestOverDue???',			isnull(i.InterestOverDue,'')),
				'???TotalDueAmt???',				isnull(i.TotalDue,0)),
				'???TotalOverDue???',				isnull(i.TotalOverDue,0)),
				'???LateFeeAmtDue???',				isnull(i.TotalFees,0)),
				'???SpecialArrangementAmount???',	isnull(i.PayArrangementAmt,0)),
				'To Be Paid by ???DelayedPayStartDate???',		isnull(i.PayArrangementComment,'')),  --msh 20180408
				'???Degree???',				'M.D.'),
				'???CurrentDate???',		convert(varchar (10),@CurrDate,101)),
				'???EndOfCurrMonth???',		convert(varchar (10),@EndOfCurrMonth,101)),
				'???CurrentMonth???',		DATENAME(Month,@CurrDate)),
				'???UserID???',				convert(varchar (10),i.UserId)),
--				'???NextDueDate???',		isnull(convert(varchar (10),dateadd(year,year(i.DateInserted)-2000,t.BaseDueDate),101),'')), -- 2000 is a base year in invoiceTemplateTable
				'???NextDueDate???',		@NextDueDate),
				'???LateFeeDate???',		convert(varchar (10),i.DateInserted -1,101)) -- 2000 is a base year in invoiceTemplateTable

--select  isnull(convert(Date,i.Loan2ApprovedDate),''),isnull(convert(Varchar(16),i.Loan2ApprovedDate),''),convert(Varchar(10),isnull(i.Loan2ApprovedDate,'')),convert(Date,i.Loan2ApprovedDate), i.Loan2ApprovedDate,*
  FROM			fn.invoices i 
  inner join	act.UserInfo u	on i.UserID = u.UserID
  inner join	act.Address a	on	u.UserID = a.UserID 
									and a.AdrCode = 'S'
									and a.AdrFlag = 0 
  inner join	dbo.mms_EmailInvoiceTemplate t
								on t.InvoiceMonth = month(i.dateinserted) 
									and t.IsSpecialArrangement = u.PayArrangementFlag
									and t.IsPastDue = case  when i.TotalOverDue > 0 then 1 else 0 end
  left join		opr.Institution inst on u.InstitutionID = inst.InstitutionID
  WHERE i.InvoiceCurrentFlag = 0
		and u.SendInvoiceByEmail in ('E','A')
		and i.DoNotSendInvoiceFlag = 0
  		and isnull(u.Email,'') <> ''
		and i.EmailQueued is null
		and i.IsDeleted = 'N'


-- update flag EmailQueued in Invoice table
update i set EmailQueued = getdate()
--select * 
--delete
from [dbo].[mms_Email]  e
	inner join fn.invoices i on e.recipients = i.Email
where 
		e.MailSent is null 
	and i.InvoiceCurrentFlag = 0
	and i.EmailQueued is null




  end try
begin catch
	--if a transaction was started, rollback
	if   @@trancount > 0
	begin
		rollback transaction
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
	return (-1)

end catch




GO

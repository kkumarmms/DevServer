SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [rpt].[p_rptMissingFDtransactions] 
AS
BEGIN
/*
-- =============================================
-- Author:		Mike Sherman
-- Create date: 2020-05-18
-- Description:	ctreates report on First Data transactions that were not recorded in SLAP
	2021-01-29 - msh - replaced Bill Wheeler's name and email
-- =============================================
*/
	SET NOCOUNT ON;

BEGIN TRY

DECLARE @RowCount int
DECLARE @body NVARCHAR(MAX)
DECLARE @subj varchar(100)
DECLARE @xml NVARCHAR(MAX)
	if exists (	
				SELECT top 1 f.Tag
				FROM [FirstDataExtract].[dbo].[FirstDataExtract] f
					left join    [SLAP].[dbo].[PaymentLog] s on f.tag = s.TransactionTag
				where f.Reference3 = 'CEFUND' 
				  and f.CustomerName not like '%test%'
				  and convert(date,TransactionDateTime) = convert(date, getdate()-1)
				  and s.TransactionTag is null
				)
BEGIN


	SET @subj = 'FD transactions NOT recorded in SLAP today:  ' +  convert(varchar(10),getdate(),101)
	SET @xml = cast (
	(
		SELECT
		f.Tag AS 'td','',
		f.CustomerName AS 'td','',
		f.CardType AS 'td','',
		convert(decimal(9,2),f.Amount) AS 'td','',
		f.AuthorizationCode AS 'td','',
		TransactionDateTime AS 'td'
		FROM [FirstDataExtract].[dbo].[FirstDataExtract] f
			left join    [SLAP].[dbo].[PaymentLog] s on f.tag = s.TransactionTag
		where f.Reference3 = 'CEFUND' 
		  and f.CustomerName not like '%test%'
		  and convert(date,TransactionDateTime) = convert(date, getdate()-1)
		  and s.TransactionTag is null
		order by TransactionDateTime desc
		  FOR XML PATH('tr'), ELEMENTS
	)
	AS NVARCHAR(MAX))



		SET @body ='<html><body>
				
				<table border = 1> 
				<tr>
					<th> FD Tag </th> 
					<th> Customer Name </th> 
					<th> Card Type   </th> 
					<th> Amount  </th>
					<th> Authorization Code </th> 
					<th> Transaction DateTime </th>
				</tr>'    
	 
		SET @body = @body + @xml +'</table></body></html>'

	EXEC msdb.dbo.sp_send_dbmail 
    @recipients = 'msherman@mms.org;mmisilo@mms.org;oteixeira@mms.org;zqureshi@mms.org;svatasoiu@mms.org;jcharlton@mms.org', 
	--@recipients = 'msherman@mms.org',
    @body = @body,
	@body_format ='HTML',
	--@query = @query, 
    @subject = @subj; 	
			
		
END
END TRY
	begin catch
		--if a transaction was started, rollback
		--if @@trancount > 0
		--begin
		--	rollback tran
		--end
			
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

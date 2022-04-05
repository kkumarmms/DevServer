SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [rpt].[p_rptPaidLoansDetailed1]
AS
BEGIN
truncate table dbo.PaidLoansDetailedReport1
INSERT INTO dbo.PaidLoansDetailedReport1
exec RPT.[p_FinancialArrangements] 1800

select * from PaidLoansDetailedReport1
END
GO

CREATE TABLE [dbo].[LoanPaymentSchedule_Temp]
(
[MMSLoanID] [tinyint] NOT NULL,
[LoanYear] [tinyint] NOT NULL,
[PrincipalBalance] [numeric] (9, 2) NULL,
[PrincipalAmtDue] [numeric] (9, 2) NULL,
[Interest] [numeric] (9, 1) NULL,
[InterestAmtDue] [numeric] (9, 2) NULL,
[TotalAmtDue] [numeric] (9, 2) NULL,
[LoanGroupingCode] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoanPaymentSchedule_Temp] ADD CONSTRAINT [PK_LoanPaymentSchedule_Temp] PRIMARY KEY CLUSTERED ([MMSLoanID], [LoanYear]) ON [PRIMARY]
GO

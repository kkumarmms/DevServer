CREATE TABLE [dbo].[Schedule_stage]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[UserId] [int] NULL,
[PrincipalBalance] [numeric] (38, 2) NULL,
[PrincipalAmtDue] [numeric] (38, 2) NULL,
[Interest] [numeric] (9, 1) NULL,
[InterestAmtDue] [numeric] (38, 2) NULL,
[InterestAmtDueCalc] [decimal] (9, 2) NULL,
[TotalAmtDue] [numeric] (38, 2) NULL,
[TotalAmtDueCalc] [numeric] (38, 7) NULL,
[LoanYear] [tinyint] NULL,
[PaymentDate] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Schedule_stage] ADD CONSTRAINT [PK_schedule_stage] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO

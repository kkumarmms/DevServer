CREATE TABLE [rpt].[MonthlyBilling]
(
[UserID] [int] NOT NULL,
[Name] [varchar] (102) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[School] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Principal Balance] [decimal] (38, 2) NULL,
[Interest Balance] [decimal] (38, 2) NULL,
[Principal Due] [decimal] (38, 2) NULL,
[Interest Due] [decimal] (38, 2) NULL,
[Late Charges] [decimal] (38, 2) NULL,
[Total Due] [decimal] (38, 2) NULL,
[DateInserted] [date] NOT NULL CONSTRAINT [DF_MonthlyBilling_DateInserted] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [rpt].[MonthlyBilling] ADD CONSTRAINT [PK_MonthlyBilling] PRIMARY KEY CLUSTERED ([UserID], [DateInserted]) ON [PRIMARY]
GO

CREATE TABLE [fn].[LoanItems]
(
[LoanItemID] [int] NOT NULL IDENTITY(1, 1),
[LoanItemGroup] [tinyint] NULL,
[LoanItemPayOrderID] [int] NOT NULL,
[LoanItemDescr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [DF_LoanItems_DateInserted] DEFAULT (getdate()),
[DateUpdated] [datetime] NOT NULL CONSTRAINT [DF_LoanItems_DateUpdated] DEFAULT (getdate()),
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanItems_IsDeleted] DEFAULT ('N'),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanItems_InsertedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanItems_UpdatedBy] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [fn].[LoanItems] ADD CONSTRAINT [pk_loanitems_pid] PRIMARY KEY CLUSTERED ([LoanItemID]) ON [PRIMARY]
GO

CREATE TABLE [fn].[LoanCurrState_Log]
(
[LoanCurrState_LogID] [int] NOT NULL IDENTITY(1, 1),
[LoanCurrStateID] [int] NOT NULL,
[UserId] [int] NULL,
[LoanID] [int] NOT NULL,
[LoanItemID] [int] NOT NULL,
[LoanItemAmt] [decimal] (9, 2) NULL,
[PayFlag] [bit] NOT NULL CONSTRAINT [DF_LoanCurrState_Log_ItemWaived] DEFAULT ((0)),
[Comments] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [DF_LoanCurrState_Log_DateInserted] DEFAULT (getdate()),
[DateUpdated] [datetime] NOT NULL CONSTRAINT [DF_LoanCurrState_Log_DateUpdated] DEFAULT (getdate()),
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanCurrState_Log_IsDeleted] DEFAULT ('N'),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanCurrState_Log_InsertedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanCurrState_Log_UpdatedBy] DEFAULT (suser_sname()),
[DateLogged] [datetime] NOT NULL CONSTRAINT [DF_LoanCurrState_Log_DateLogged] DEFAULT (getdate()),
[HostUpdated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanCurrState_Log_HostUpdated] DEFAULT (host_name())
) ON [PRIMARY]
GO
ALTER TABLE [fn].[LoanCurrState_Log] ADD CONSTRAINT [pk_loancurrstate_Log_pid] PRIMARY KEY CLUSTERED ([LoanCurrState_LogID]) ON [PRIMARY]
GO

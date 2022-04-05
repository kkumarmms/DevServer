CREATE TABLE [dbo].[OperationsLog]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[UserId] [int] NULL,
[ApplicationId] [int] NULL,
[Email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoanId] [int] NULL,
[LoanPaymentId] [int] NULL,
[Comment] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateInserted] [datetime] NULL CONSTRAINT [DF_OperationsLog_DateInserted] DEFAULT (getdate()),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OperationsLog] ADD CONSTRAINT [PK_OperationsLog] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO

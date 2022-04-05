CREATE TABLE [app].[ApplFinancials]
(
[ApplFinancialsID] [int] NOT NULL IDENTITY(1, 1),
[ApplicationId] [int] NOT NULL,
[FinType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [decimal] (9, 2) NULL,
[DisplayOrder] [int] NOT NULL CONSTRAINT [DF_ApplFinancials_Order] DEFAULT ((0)),
[IsDeleted] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ApplFinancials_IsDeleted] DEFAULT ('N'),
[DateInserted] [datetime2] NOT NULL CONSTRAINT [DF_ApplFinancials_DateInserted] DEFAULT (getdate()),
[DateUpdated] [datetime2] NULL,
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [app].[ApplFinancials] ADD CONSTRAINT [PK_app.ApplFinancials] PRIMARY KEY CLUSTERED ([ApplFinancialsID]) ON [PRIMARY]
GO
ALTER TABLE [app].[ApplFinancials] ADD CONSTRAINT [FK_ApplFinancials_Application] FOREIGN KEY ([ApplicationId]) REFERENCES [app].[Application] ([ApplicationID])
GO

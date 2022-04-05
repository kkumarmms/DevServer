CREATE TABLE [dbo].[Audit]
(
[AuditID] [int] NOT NULL IDENTITY(1, 1),
[Type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryKeyField] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryKeyValue] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FieldName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldValue] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewValue] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL CONSTRAINT [DF__Audit__UpdateDat__3EA749C6] DEFAULT (getdate()),
[UserName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

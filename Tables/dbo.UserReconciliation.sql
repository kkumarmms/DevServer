CREATE TABLE [dbo].[UserReconciliation]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MiddleInitial] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Title] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SSNumber] [varbinary] (2000) NULL,
[SSNHashed] [varbinary] (2000) NULL,
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CellPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Processed] [bit] NULL CONSTRAINT [DF_UserReconciliation_Processed] DEFAULT ((0)),
[Comment] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateInserted] [datetime] NULL CONSTRAINT [DF_UserReconciliation_DateInserted] DEFAULT (getdate()),
[IpAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserReconciliation] ADD CONSTRAINT [PK_UserReconciliation] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[UserImpersonationRequests]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[UserIdToImpersonate] [int] NOT NULL,
[ImpersonateBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ValidUntil] [datetime] NULL,
[UniqueId] [uniqueidentifier] NULL CONSTRAINT [DF_act.UserImpersonationRequests_UniqueId] DEFAULT (newid()),
[Used] [bit] NULL CONSTRAINT [DF_act.UserImpersonationRequests_Used] DEFAULT ((0)),
[OverrideRORestriction] [bit] NULL CONSTRAINT [DF_act.UserImpersonationRequests_OverrideRORestriction] DEFAULT ((0)),
[DateInserted] [datetime] NULL CONSTRAINT [DF_act.UserImpersonationRequests_DateInserted] DEFAULT (getdate()),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateUpdated] [datetime] NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserImpersonationRequests] ADD CONSTRAINT [PK_act.UserImpersonationRequests] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO

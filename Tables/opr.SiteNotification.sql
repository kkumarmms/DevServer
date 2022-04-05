CREATE TABLE [opr].[SiteNotification]
(
[MessageId] [int] NOT NULL IDENTITY(1, 1),
[DisplayOrder] [int] NULL CONSTRAINT [DF_SiteNotification_DisplayOrder] DEFAULT ((0)),
[Message] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageStartDate] [datetime] NOT NULL,
[MessageEndDate] [datetime] NULL,
[ShowOnlyIf] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShowOnlyIfCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Comment] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_SiteNotification_Active] DEFAULT ((1)),
[DateInserted] [datetime] NULL CONSTRAINT [DF_SiteNotification_DateInserted] DEFAULT (getdate()),
[DateUpdated] [datetime] NULL,
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

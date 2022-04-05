CREATE TABLE [dbo].[mms_Email]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Profile_Name] [sys].[sysname] NULL,
[recipients] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Copy_Recipients] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BCC_Recipients] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subject] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Body] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Body_Format] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Attachments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Created] [datetime] NULL CONSTRAINT [DF__mms_Email__Creat__5535A963] DEFAULT (getdate()),
[UserName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__mms_Email__UserN__5629CD9C] DEFAULT (suser_sname()),
[MailSent] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mms_Email] ADD CONSTRAINT [PK_mms_Email] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO

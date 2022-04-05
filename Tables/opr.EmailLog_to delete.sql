CREATE TABLE [opr].[EmailLog_to delete]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[EmailTo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailCC] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailBCC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailFrom] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailProfile] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subject] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Body] [varchar] (6000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BodyFormat] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_opr.EmailLog_BodyFormat] DEFAULT ('HTML'),
[AttachementLink] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SentOn] [datetime] NULL,
[Sent] [bit] NULL CONSTRAINT [DF_opr.EmailLog_Sent] DEFAULT ((0)),
[DateInserted] [datetime] NULL CONSTRAINT [DF_opr.EmailLog_DateInserted] DEFAULT (getdate()),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [opr].[EmailLog_to delete] ADD CONSTRAINT [PK.EmailLog] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO

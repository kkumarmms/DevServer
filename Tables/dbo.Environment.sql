CREATE TABLE [dbo].[Environment]
(
[Id] [int] NULL,
[Environment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatabaseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WebLink] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdminFlag] [bit] NULL,
[ReportServerUrl] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportsPath] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

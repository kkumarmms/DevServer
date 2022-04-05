CREATE TABLE [dbo].[DBA_ErrorLog]
(
[ErrLogID] [int] NOT NULL IDENTITY(1, 1),
[ErrNumber] [int] NULL,
[ErrSeverity] [int] NULL,
[ErrState] [int] NULL,
[ErrProc] [nvarchar] (126) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrLine] [int] NULL,
[ErrMessage] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QueryString] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [Def_DBA_ErrorLog_DateInserted] DEFAULT (getdate()),
[UserInserted] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_DBA_ErrorLog_UserInserted] DEFAULT (suser_sname()),
[HostInserted] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Def_DBA_ErrorLog_HostInserted] DEFAULT (host_name()),
[DateUpdated] [datetime] NULL,
[UserUpdated] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HostUpdated] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--create trigger
CREATE TRIGGER [dbo].[tu_DBA_ErrorLog] 
ON [dbo].[DBA_ErrorLog]
FOR UPDATE
AS

SET NOCOUNT ON

/* ERwin Builtin Tuesday, May 05, 2009 7:38:22 AM */
/*  trigger on DBA_ErrorLog */
/* default body for tu_DBA_ErrorLog */
BEGIN
	update tbl
	set DateUpdated = GETDATE(),
		UserUpdated = SYSTEM_USER,
		HostUpdated = HOST_NAME()
	from inserted i, deleted d, dbo.DBA_ErrorLog tbl
	where i.ErrLogID = d.ErrLogID
	  and i.ErrLogID = tbl.ErrLogID
	  and tbl.ErrLogID = d.ErrLogID
END


GO
ALTER TABLE [dbo].[DBA_ErrorLog] ADD CONSTRAINT [PK_DBA_ErrorLog] PRIMARY KEY CLUSTERED ([ErrLogID]) ON [PRIMARY]
GO

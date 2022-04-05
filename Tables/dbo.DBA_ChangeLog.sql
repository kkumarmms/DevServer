CREATE TABLE [dbo].[DBA_ChangeLog]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[EventData] [xml] NOT NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [DF__DBA_Chang__DateI__0BC6C43E] DEFAULT (getdate()),
[UserInserted] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__DBA_Chang__UserI__0CBAE877] DEFAULT (suser_sname()),
[HostInserted] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__DBA_Chang__HostI__0DAF0CB0] DEFAULT (host_name()),
[DateUpdated] [datetime] NULL,
[UserUpdated] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HostUpdated] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[tu_DBA_ChangeLog]
			ON [dbo].[DBA_ChangeLog]  
			FOR UPDATE 
			AS
				set nocount on

				update c
				set DateUpdated = getdate(),
					UserUpdated = system_user,
					HostUpdated = host_name()
				from inserted i, dbo.DBA_ChangeLog c, deleted d
				where i.ID = c.ID 
				  and d.ID = c.ID 
				  and d.ID = i.ID
GO
ALTER TABLE [dbo].[DBA_ChangeLog] ADD CONSTRAINT [PK_DBA_ChangeLog] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[DBA_ChangeLog] TO [public]
GO

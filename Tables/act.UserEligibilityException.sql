CREATE TABLE [act].[UserEligibilityException]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[UserId] [int] NOT NULL,
[InstitutionId] [int] NOT NULL,
[StartDate] [datetime] NULL CONSTRAINT [DF_act.UserEligibilityException_StartDate] DEFAULT (getdate()),
[EndDate] [datetime] NULL CONSTRAINT [DF_act.UserEligibilityException_EndDate] DEFAULT (getdate()),
[Active] [bit] NULL CONSTRAINT [DF_act.UserEligibilityException_Active] DEFAULT ((1)),
[DateInserted] [datetime] NULL CONSTRAINT [DF_act.UserEligibilityException_DateInserted] DEFAULT (getdate()),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateUpdated] [datetime] NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [act].[UserEligibilityException] ADD CONSTRAINT [PK_act.UserEligibilityException] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO

CREATE TABLE [act].[UserInfo_Hist]
(
[UserID] [int] NOT NULL IDENTITY(1, 1),
[UserType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MiddleInitial] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AKA] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Password] [varbinary] (1000) NULL,
[SSNumber] [varbinary] (1000) NULL,
[SSNHashed] [varbinary] (1000) NULL,
[InstitutionID] [smallint] NULL,
[MMSLoanID] [int] NULL,
[UserStatus] [tinyint] NULL,
[UniqueIdentifier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserActivatedDate] [datetime2] NULL,
[Remarks] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ForgottenLinkExpiry] [datetime2] NULL,
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateInserted] [datetime2] NULL,
[DateUpdated] [datetime2] NULL,
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

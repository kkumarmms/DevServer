CREATE TABLE [act].[UserInfoBak]
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
[SSNumber] [varbinary] (2000) NULL,
[SSNHashed] [varbinary] (2000) NULL,
[InstitutionID] [smallint] NULL,
[MMSLoanID] [int] NULL CONSTRAINT [DF_UserInfoBak_MMSLoanID] DEFAULT ((-1)),
[GraduationYear] [int] NULL,
[UserStatus] [int] NULL,
[PayArrangementFlag] [bit] NULL CONSTRAINT [DF_UserInfoBak_PayArrangementFlag] DEFAULT ((0)),
[PayArrangementAmt] [decimal] (9, 2) NULL CONSTRAINT [DF_UserInfoBak_PayArrangementAmt] DEFAULT ((0)),
[DelayedPayStartDate] [date] NULL,
[PayArrangementComment] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UserInfoBak_PayArrangementComment] DEFAULT (''),
[UniqueIdentifier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UserInfoBak_UniqueIdentifier] DEFAULT (newid()),
[UserActivatedDate] [datetime2] NULL,
[Remarks] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ForgottenLinkExpiry] [datetime2] NULL CONSTRAINT [DF_UserInfoBak_ForgottenLinkExpiry] DEFAULT (getdate()),
[SendInvoiceByEmail] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UserInfoBak_SendInvoiceByEmail] DEFAULT ('P'),
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UserInfoBak_IsDeleted] DEFAULT ('N'),
[DateInserted] [datetime2] NOT NULL CONSTRAINT [DF__UserInfoBak__DateIn__36D11DD4] DEFAULT (getdate()),
[DateUpdated] [datetime2] NOT NULL CONSTRAINT [DF__UserInfoBak__DateUp__37C5420D] DEFAULT (getdate()),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UserInfoBak_InsertedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UserInfoBak_UpdatedBy] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [act].[UserInfoBak] ADD CONSTRAINT [PK__UserBak__1788CCAC336AA144] PRIMARY KEY CLUSTERED ([UserID]) ON [PRIMARY]
GO
ALTER TABLE [act].[UserInfoBak] ADD CONSTRAINT [Institution_UserBak_FK1] FOREIGN KEY ([InstitutionID]) REFERENCES [opr].[Institution] ([InstitutionID])
GO

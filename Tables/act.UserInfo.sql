CREATE TABLE [act].[UserInfo]
(
[UserID] [int] NOT NULL IDENTITY(1, 1),
[UserType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MiddleInitial] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AKA] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SchoolNotificationEmail] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Password] [varbinary] (1000) NULL,
[SSNumber] [varbinary] (2000) NULL,
[SSNHashed] [varbinary] (2000) NULL,
[InstitutionID] [smallint] NULL,
[MMSLoanID] [int] NULL CONSTRAINT [DF_UserInfo_MMSLoanID] DEFAULT ((-1)),
[GraduationYear] [int] NULL,
[UserStatus] [int] NULL,
[PayArrangementFlag] [bit] NULL CONSTRAINT [DF_UserInfo_PayArrangementFlag] DEFAULT ((0)),
[PayArrangementAmt] [decimal] (9, 2) NULL CONSTRAINT [DF_UserInfo_PayArrangementAmt] DEFAULT ((0)),
[DelayedPayStartDate] [date] NULL,
[PayArrangementComment] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UserInfo_PayArrangementComment] DEFAULT (''),
[UniqueIdentifier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UserInfo_UniqueIdentifier] DEFAULT (newid()),
[UserActivatedDate] [datetime2] NULL,
[Remarks] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ForgottenLinkExpiry] [datetime2] NULL CONSTRAINT [DF_UserInfo_ForgottenLinkExpiry] DEFAULT (getdate()),
[SendInvoiceByEmail] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UserInfo_SendInvoiceByEmail] DEFAULT ('P'),
[DoNotSendInvoiceFlag] [bit] NULL CONSTRAINT [DF_UserInfo_StopPaymentFlag] DEFAULT ((0)),
[DoNotSendInvoiceComment] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UserInfo_IsDeleted] DEFAULT ('N'),
[DateInserted] [datetime2] NOT NULL CONSTRAINT [DF__UserInfo__DateIn__36D11DD4] DEFAULT (getdate()),
[DateUpdated] [datetime2] NOT NULL CONSTRAINT [DF__UserInfo__DateUp__37C5420D] DEFAULT (getdate()),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UserInfo_InsertedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UserInfo_UpdatedBy] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [act].[UserInfo] ADD CONSTRAINT [PK__User__1788CCAC336AA144] PRIMARY KEY CLUSTERED ([UserID]) ON [PRIMARY]
GO
ALTER TABLE [act].[UserInfo] ADD CONSTRAINT [Institution_User_FK1] FOREIGN KEY ([InstitutionID]) REFERENCES [opr].[Institution] ([InstitutionID])
GO

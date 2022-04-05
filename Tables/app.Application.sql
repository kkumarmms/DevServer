CREATE TABLE [app].[Application]
(
[ApplicationID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NOT NULL,
[OfficerId] [int] NOT NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleInitial] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressID] [int] NULL,
[ParentAddressID] [int] NULL,
[IsUSCitizen] [bit] NULL,
[IsMAResident] [bit] NULL,
[IsMMSStudent] [bit] NULL,
[MMSStudentID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HaveLoanCEF] [bit] NULL,
[MDDegreeFromSchool] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDDegreeDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationAfterGrad] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsMarried] [bit] NULL,
[SpouseOccupation] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Children] [tinyint] NULL CONSTRAINT [DF_Application_Children] DEFAULT ((0)),
[ChildsAge] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSpouseApplForLoan] [bit] NULL,
[Comments] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApplicantSignature] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApplicantSignedDate] [date] NULL,
[MMSLoanID] [tinyint] NOT NULL,
[LoanAmt] [decimal] (9, 2) NULL CONSTRAINT [DF_Application_LoanAmt] DEFAULT ((0)),
[OfficerSignature] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficerSignedDate] [date] NULL,
[MMSAmt] [decimal] (9, 2) NULL,
[MMSSignature] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MMSSignedDate] [date] NULL,
[ApplStatus] [int] NULL,
[LoanApprovedFlag] [bit] NULL CONSTRAINT [DF_Application_LoanApprovedFlag] DEFAULT ((0)),
[LoanApprovedDate] [date] NULL,
[Uniqueidentifier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Application_uniqueidentifier] DEFAULT (newid()),
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Application_IsDeleted] DEFAULT ('N'),
[DateInserted] [datetime2] NULL CONSTRAINT [DF_Application_DateInserted] DEFAULT (getdate()),
[DateUpdated] [datetime2] NULL,
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LockedForStudent] [bit] NULL CONSTRAINT [DF_Application_LockedForStudent] DEFAULT ((0)),
[LockedForOfficer] [bit] NULL CONSTRAINT [DF_Application_LockedForOfficer] DEFAULT ((0)),
[LockedForAdmin] [bit] NULL CONSTRAINT [DF_Application_LockedForAdmin] DEFAULT ((0)),
[OfficerRejectComment] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Application_OfficerRejectComment] DEFAULT (''),
[MMSPrivateComment] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Application_MMSPrivateComment] DEFAULT (''),
[MMSLoanSignedDate] [date] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Mike Sherman
-- Create date: 2014-03-26
-- Description:	
-- =============================================
CREATE TRIGGER	[app].[tu_Application] 
   ON			 [app].[Application]
   FOR UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		update  app
	set      
      [DateUpdated]= getdate()
      ,[UpdatedBy] = suser_sname()
	from  inserted i, deleted d, app.Application app
	where i.ApplicationID = d.ApplicationID
	and  app.ApplicationID = i.ApplicationID
    -- Insert statements for trigger here

END
GO
ALTER TABLE [app].[Application] ADD CONSTRAINT [PK_app.Application] PRIMARY KEY CLUSTERED ([ApplicationID]) ON [PRIMARY]
GO
ALTER TABLE [app].[Application] ADD CONSTRAINT [FK_Application_UserInfo] FOREIGN KEY ([UserID]) REFERENCES [act].[UserInfo] ([UserID])
GO

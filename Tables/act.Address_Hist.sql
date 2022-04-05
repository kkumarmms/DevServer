CREATE TABLE [act].[Address_Hist]
(
[AddressID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NOT NULL,
[AdrCode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdrFlag] [tinyint] NOT NULL,
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneCell] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateInserted] [datetime2] NULL CONSTRAINT [DF_Address_Hist_DateInserted] DEFAULT (getdate()),
[DateUpdated] [datetime2] NULL CONSTRAINT [DF_Address_Hist_DateUpdated] DEFAULT (getdate()),
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Address_Hist_IsDeleted] DEFAULT ('N'),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Address_Hist_InsertedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Address_Hist_UpdatedBy] DEFAULT (suser_sname())
) ON [PRIMARY]
GO

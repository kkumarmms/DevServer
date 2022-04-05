CREATE TABLE [act].[Address]
(
[AddressID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NOT NULL,
[AdrCode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdrFlag] [tinyint] NOT NULL CONSTRAINT [DF_Address_AdrFlag] DEFAULT ((0)),
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[State] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneCell] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateInserted] [datetime2] NOT NULL CONSTRAINT [DF_Address_DateInserted] DEFAULT (getdate()),
[DateUpdated] [datetime2] NOT NULL CONSTRAINT [DF_Address_DateUpdated] DEFAULT (getdate()),
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Address_IsDeleted] DEFAULT ('N'),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Address_InsertedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Address_UpdatedBy] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [act].[Address] ADD CONSTRAINT [PK_Address] PRIMARY KEY CLUSTERED ([AddressID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Address] ON [act].[Address] ([UserID], [AdrCode], [AdrFlag]) ON [PRIMARY]
GO
ALTER TABLE [act].[Address] ADD CONSTRAINT [FK_Address_UserInfo] FOREIGN KEY ([UserID]) REFERENCES [act].[UserInfo] ([UserID])
GO

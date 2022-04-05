CREATE TABLE [dbo].[PaymentType]
(
[PaymentTypeID] [smallint] NOT NULL IDENTITY(1, 1),
[Code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [DF__PaymentTy__DateI__4589517F] DEFAULT (getdate()),
[DateUpdated] [datetime] NOT NULL CONSTRAINT [DF__PaymentTy__DateU__467D75B8] DEFAULT (getdate()),
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PaymentType] ADD CONSTRAINT [PK__PaymentT__BA430B1543A1090D] PRIMARY KEY CLUSTERED ([PaymentTypeID]) ON [PRIMARY]
GO

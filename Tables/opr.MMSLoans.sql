CREATE TABLE [opr].[MMSLoans]
(
[MMSLoanID] [smallint] NOT NULL IDENTITY(1, 1),
[Code] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoanAmount] [decimal] (9, 2) NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoanTerm] [smallint] NULL,
[LegacySchedCode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [DF__tmp_ms_xx__DateI__6E2152BE] DEFAULT (getdate()),
[DateUpdated] [datetime] NOT NULL CONSTRAINT [DF__tmp_ms_xx__DateU__6F1576F7] DEFAULT (getdate()),
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MMSLoans_InsertedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MMSLoans_UpdatedBy] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [opr].[MMSLoans] ADD CONSTRAINT [PK__tmp_ms_x__2F1E930EA959A608] PRIMARY KEY CLUSTERED ([MMSLoanID]) ON [PRIMARY]
GO

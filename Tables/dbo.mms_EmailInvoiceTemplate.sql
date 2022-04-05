CREATE TABLE [dbo].[mms_EmailInvoiceTemplate]
(
[EmailTemplateID] [int] NOT NULL IDENTITY(1, 1),
[InvoiceMonth] [tinyint] NULL,
[IsPastDue] [bit] NULL,
[IsSpecialArrangement] [bit] NULL,
[EmailBody] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BaseDueDate] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mms_EmailInvoiceTemplate] ADD CONSTRAINT [PK_mms_EmailInvoiceTemplate] PRIMARY KEY CLUSTERED ([EmailTemplateID]) ON [PRIMARY]
GO

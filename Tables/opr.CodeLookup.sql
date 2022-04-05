CREATE TABLE [opr].[CodeLookup]
(
[CodeDescID] [int] NOT NULL IDENTITY(1, 1),
[CodeType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FieldName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodeDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodeDescriptionInternal] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [opr].[CodeLookup] ADD CONSTRAINT [PK_CodeLookup] PRIMARY KEY CLUSTERED ([CodeDescID]) ON [PRIMARY]
GO

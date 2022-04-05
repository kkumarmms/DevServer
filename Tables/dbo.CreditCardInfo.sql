CREATE TABLE [dbo].[CreditCardInfo]
(
[CCInfo_ID] [int] NOT NULL IDENTITY(1, 1),
[ClientToken] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardInfo] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CreditCardInfo] ADD CONSTRAINT [PK_CreditCardInfo] PRIMARY KEY CLUSTERED ([CCInfo_ID]) ON [PRIMARY]
GO

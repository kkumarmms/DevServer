CREATE TABLE [rpt].[PrincipalBySchool]
(
[Count of Accounts] [int] NULL,
[Sum of Principal Balance] [decimal] (9, 2) NULL,
[School] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateCreated] [datetime] NULL CONSTRAINT [DF_rpt.PrincipalBySchool_DateCreated] DEFAULT (getdate())
) ON [PRIMARY]
GO

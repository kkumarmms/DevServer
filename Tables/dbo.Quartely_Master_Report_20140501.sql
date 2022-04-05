CREATE TABLE [dbo].[Quartely_Master_Report_20140501]
(
[ACCOUNTNO] [nvarchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstOfLASTNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[finit] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstOfothername] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxOfloan_number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinOfdateloan] [datetime2] NULL,
[MaxOfdateloan] [datetime2] NULL,
[SumOfprincipal] [float] NULL,
[SumOfprincipal_paid_to_date] [float] NULL,
[PRINBAL] [float] NULL,
[SumOftotal_interest] [float] NULL,
[SumOfinterest_paid_to_date] [float] NULL,
[INTBAL] [float] NULL,
[prinowed] [float] NULL,
[intowed] [float] NULL,
[TOTDUE] [float] NULL,
[MaxOflast_payment_date] [datetime2] NULL,
[outstandingbal] [float] NULL,
[SumOfaccrued_late_charges] [float] NULL
) ON [PRIMARY]
GO

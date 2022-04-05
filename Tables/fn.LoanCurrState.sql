CREATE TABLE [fn].[LoanCurrState]
(
[LoanCurrStateID] [int] NOT NULL IDENTITY(1, 1),
[UserId] [int] NULL,
[LoanID] [int] NOT NULL,
[LoanItemID] [int] NOT NULL,
[LoanItemAmt] [decimal] (9, 2) NULL,
[PayFlag] [bit] NOT NULL CONSTRAINT [DF_LoanCurrState_ItemWaived] DEFAULT ((0)),
[Comments] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateInserted] [datetime] NOT NULL CONSTRAINT [DF_LoanCurrState_DateInserted] DEFAULT (getdate()),
[DateUpdated] [datetime] NOT NULL CONSTRAINT [DF_LoanCurrState_DateUpdated] DEFAULT (getdate()),
[IsDeleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanCurrState_IsDeleted] DEFAULT ('N'),
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanCurrState_InsertedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoanCurrState_UpdatedBy] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Mike Sherman
-- Create date: 2014-04-03
-- Description:	Log any changes to loancurrentstate table
--ALTER trigger [fn].[LoanCurrState_ChangeTracking] on [fn].[LoanCurrState] for insert, update, delete
-- =============================================
CREATE TRIGGER [fn].[tu_LoanCurrState]
   ON [fn].[LoanCurrState] 
   AFTER  DELETE, UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if	update(LoanItemID) or 
		update(LoanItemAmt) or
		update(PayFlag) or
		update(Comments) 
	begin
			Insert [fn].[LoanCurrState_Log]
				( 
				[LoanCurrStateID]
				,[UserId]
				,[LoanID]
				,[LoanItemID]
				,[LoanItemAmt]
				,[PayFlag]
				,[Comments]
				,[DateInserted]
				,[DateUpdated]
				,[IsDeleted]
				,[InsertedBy]
				,[UpdatedBy]
				,[DateLogged]
				  )
			select  
				d.[LoanCurrStateID]
				,d.[UserId]
				,d.[LoanID]
				,d.[LoanItemID]
				,d.[LoanItemAmt]
				,d.[PayFlag]
				,d.[Comments]
				,d.[DateInserted]
				,d.[DateUpdated]
				,d.[IsDeleted]
				,d.[InsertedBy]
				,	suser_sname()
				,[DateLogged] = getdate()
			from [fn].[LoanCurrState] l , deleted d
			where l.[LoanCurrStateID] = d.[LoanCurrStateID]

	update  l
	set [DateUpdated] = getdate()
		,[UpdatedBy] = suser_sname()
	from 	 [fn].[LoanCurrState] l , deleted d
			where l.[LoanCurrStateID] = d.[LoanCurrStateID]
	end


END
GO
ALTER TABLE [fn].[LoanCurrState] ADD CONSTRAINT [pk_loancurrstate_pid] PRIMARY KEY CLUSTERED ([LoanCurrStateID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LoanCurrState_LoanID] ON [fn].[LoanCurrState] ([LoanID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LoanCurrState_UserID] ON [fn].[LoanCurrState] ([UserId]) ON [PRIMARY]
GO
ALTER TABLE [fn].[LoanCurrState] ADD CONSTRAINT [FK_LoanCurrState_Loans] FOREIGN KEY ([LoanID]) REFERENCES [fn].[Loans] ([LoanID])
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[TestSSRS]
AS
BEGIN
SELECT * FROM fn.Loans
END
GO
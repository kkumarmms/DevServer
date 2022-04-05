SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [rpt].[p_rptPaidLoansDetailed4]
	(@FromDate date
	,@ToDate date
	,@LoanDate date)
AS 
BEGIN

--Creating Temp Table for LastPaymentApply Column
--msh please, format all create table statements for readability
--kk Formatted the create table statements on February 14, 2022


--CREATE TABLE #PaidOffLoans
--(
--	LoanID int
--)


CREATE TABLE #GetLoanDate
(
	UserID int,
	LoanID int,
	LoanDate datetime
)


CREATE TABLE #LastPayment
	(
		UserID int,
		LoanID int,
		LoanPaymentID int,
		LastPaymentDate datetime,
		LastPaymentAmt decimal(9,2)
	)


--Creating Temp Table for AmountAppliedToPrincipalBalance Column
CREATE TABLE #PrincipalBalance
	(
		UserID int,
		LoanID int,
		LoanNumber int,
		LoanPaymentID int,
		LastPaymentDate datetime,
		Principal decimal(9,2)
	)


--Creating Temp Table for AmountAppliedToInterest Column
CREATE TABLE #Interest
	(
		UserID int,
		LoanID int,
		LoanNumber int,
		LoanPaymentID int,
		LastPaymentDate datetime,
		Interest decimal(9,2)
	)


--Creating Temp Table for TotalInterestPaid Column
CREATE TABLE #InterestPaid
	(
		UserID int,
		LoanID int,
		Interest decimal(9,2)
	)


--Creating Temp Table for TotalLateChargesPaid Column
CREATE TABLE #LateCharges
	(
		LoanID int,
		LateFee decimal(9,2)
	)


--Creating Temp Table for PaidOffin#Months Column
CREATE TABLE #DateDifference
	(
		LoanID int,
		DateDif int
	)

CREATE TABLE #DateDifferenceYear
	(
		LoanID int,
		NoOfYears float
	)


--Creating Temp Table for LastInterestRate Column
CREATE TABLE #LastInterest
	(
		LoanID int,
		MMSLoanID smallint,
		YearOfLoan tinyint,
		InterestRate numeric (9,1)
	)


--Inserting Values into LastPaymentApply Column
		--msh this is not a last payment. this is max paid amount per user

--INSERT INTO #PaidOffLoans
--SELECT DISTINCT fn.LoanCurrState.LoanID
--FROM fn.LoanCurrState inner join fn.Loans on fn.Loans.LoanID = fn.LoanCurrState.LoanID
--WHERE  (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X'))


INSERT INTO #GetLoanDate
SELECT UserID, LoanID, LoanApprovedDate
FROM fn.Loans
WHERE LoanApprovedDate >= @LoanDate


;WITH LastDate
AS 
	(
		SELECT 
			lp.UserID,
			l.LoanID,
			MAX(lp.PaymentDate) LastPaymentDate,
			MAX(lp.LoanPaymentID) LastPaymentID
		FROM fn.LoanPaymentApply lp
		INNER JOIN fn.Loans l ON lp.LoanID = l.LoanID
		GROUP BY lp.UserID, l.LoanID
	)
INSERT INTO #LastPayment
SELECT 
	p.UserID, 
	l.LoanID,
	l.LastPaymentID,
	l.LastPaymentDate, 
	p.TotalPaidAmt
FROM fn.LoanPayment  p 
INNER JOIN LastDate l 
ON l.UserID = p.UserID AND l.LastPaymentDate = p.PaymentDate
WHERE 
	l.LastPaymentDate BETWEEN @FromDate and @ToDate


--msh please, format all  statements for readability
--kk Formatted the insert into statements on February 14, 2022

--Inserting Values into AmountAppliedToPrincipalBalance Column
-- does not look right. why did you hardcode paayment dates filter? you need to find LAST payment applied to Principal and Interest
--kk Made changes to this table for getting the correct values on February 17, 2022

INSERT INTO #PrincipalBalance
SELECT 
	p.UserID,
	p.LoanID,
	p.LoanSeqNum,
	p.LoanPaymentID,
	l.LastPaymentDate,
	SUM(p.AppliedAmt)
FROM fn.LoanPaymentApply p
INNER JOIN #LastPayment l 
on l.LoanID = p.LoanID AND l.LoanPaymentID = p.LoanPaymentID
WHERE 
	(p.LoanItemID = 1 OR p.LoanItemID = 2 OR p.LoanItemID = 10)
GROUP BY p.UserID, p.LoanID, p.LoanSeqNum, l.LastPaymentDate, p.LoanPaymentID


--Inserting Values into AmountAppliedToInterest Column
-- does not look right. why did you hardcode paayment dates filter? you need to find LAST payment applied to Principal and Interest
--kk Made changes to this table for getting the correct values on February 17, 2022

INSERT INTO #Interest
SELECT 
	p.UserID,
	p.LoanID,
	p.LoanSeqNum,
	p.LoanPaymentID,
	l.LastPaymentDate,
	SUM(p.AppliedAmt)
FROM fn.LoanPaymentApply p
INNER JOIN #LastPayment l 
on l.LoanID = p.LoanID AND l.LoanPaymentID = p.LoanPaymentID
WHERE 
	(p.LoanItemID = 3 OR p.LoanItemID = 4)
GROUP BY p.UserID, p.LoanID, p.LoanSeqNum, l.LastPaymentDate, p.LoanPaymentID


--Inserting Values into TotalInterestPaid Column
INSERT INTO #InterestPaid
SELECT 
	fn.LoanCurrState.UserId,
	fn.LoanCurrState.LoanID, 
	fn.LoanCurrState.LoanItemAmt
FROM fn.LoanCurrState
WHERE 
	fn.LoanCurrState.LoanItemID = 15
GROUP BY fn.LoanCurrState.UserId, fn.LoanCurrState.LoanID, fn.LoanCurrState.LoanItemAmt


--Inserting Values into TotalLateChargesPaid Column
INSERT INTO #LateCharges
SELECT 
	LoanID, 
	LoanItemAmt
FROM fn.LoanCurrState
WHERE LoanItemID = 18
GROUP BY LoanId, LoanItemAmt


--Inserting Values into PaidOffin#Months Column
--msh LoanID is a primary key in the table. why do you need Group BY? does not make sence
--kk If LoanID is not used in GROUP BY, the following error will come up-
--kk Column 'fn.Loans.LoanID' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
INSERT INTO #DateDifference
SELECT 
	fn.Loans.LoanID, 
	DATEDIFF(month, fn.Loans.LoanApprovedDate, fn.Loans.LoanLastPaymentDate) 
FROM fn.Loans 
GROUP BY fn.Loans.LoanID, fn.Loans.LoanSeqNum , DATEDIFF(month, fn.Loans.LoanApprovedDate, fn.Loans.LoanLastPaymentDate)


INSERT INTO #DateDifferenceYear
SELECT 
	fn.Loans.LoanID, 
	CAST(DATEDIFF(month, fn.Loans.LoanApprovedDate, fn.Loans.LoanLastPaymentDate) As float)/12 As 'NoOfYears'
FROM fn.Loans


--Inserting Values into LastInterestRate Column
--msh LoanID is a primary key in the table. why do you need Group BY? does not make sence. 
--kk If UserID is not used in GROUP BY, the following error will come up-
--kk Column 'fn.Loans.UserID' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
INSERT INTO #LastInterest
SELECT 
	fn.Loans.LoanID, 
	fn.Loans.MMSLoanID, 
	fn.Loans.YearOfLoan, 
	dbo.LoanPaymentSchedule.Interest
FROM fn.Loans
INNER JOIN dbo.LoanPaymentSchedule
ON fn.Loans.MMSLoanID = dbo.LoanPaymentSchedule.MMSLoanID
WHERE 
	fn.Loans.YearOfLoan = dbo.LoanPaymentSchedule.LoanYear
GROUP BY fn.Loans.LoanID, fn.Loans.LoanSeqNum,fn.Loans.MMSLoanID, fn.Loans.YearOfLoan, dbo.LoanPaymentSchedule.Interest


--Getting the values for all the columns
--Added CASE Statements on March 11, 2022
SELECT Distinct
		    		--UserID of Student
					'Account' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN act.UserInfo.UserID ELSE act.UserInfo.UserID END
					--Full Name of the student
					,CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN rtrim(act.UserInfo.LastName) + ', ' + rtrim(act.UserInfo.FirstName) ELSE rtrim(act.UserInfo.LastName) + ', ' + rtrim(act.UserInfo.FirstName) END as 'Name' 
					--Name of Institution that Student studies in
					,CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN opr.Institution.InstitutionName ELSE opr.Institution.InstitutionName END as 'Institution' 
					--Loan Number for the Loan that the student has taken (1 or 2)
					,'Loan Number' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN fn.Loans.LoanSeqNum ELSE fn.Loans.LoanSeqNum END
					--Date on which Loan 1 was approved
--msh why do you take MAX(date)??
--kk Removed MAX function from Loan 1 Date on February 14, 2022
--kk Converted datetime to date on February 14, 2022
					,'Loan 1 Date' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN CASE WHEN fn.Loans.LoanSeqNum = 1 THEN CONVERT(date, fn.Loans.LoanApprovedDate) END ELSE CASE WHEN fn.Loans.LoanSeqNum = 1 THEN CONVERT(date, fn.Loans.LoanApprovedDate) END END
					--Description for Loan 1
					,'Loan 1 Type' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN CASE WHEN fn.Loans.LoanSeqNum = 1 THEN opr.MMSLoans.Description END ELSE CASE WHEN fn.Loans.LoanSeqNum = 1 THEN opr.MMSLoans.Description END END
					,'Loan 1 Status' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN CASE WHEN fn.Loans.LoanSeqNum = 1 THEN fn.Loans.LoanStatus END ELSE CASE WHEN fn.Loans.LoanSeqNum = 1 THEN fn.Loans.LoanStatus END END
					--Date on which Loan 2 was approved
--msh why do you take MAX(date)?? 
--kk Removed MAX function from Loan 2 Date on February 14, 2022
--kk Converted datetime to date on February 14, 2022
					,'Loan 2 Date' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN CASE WHEN fn.Loans.LoanSeqNum = 2 THEN CONVERT(date, fn.Loans.LoanApprovedDate) END ELSE CASE WHEN fn.Loans.LoanSeqNum = 2 THEN CONVERT(date, fn.Loans.LoanApprovedDate) END END
					--Description for Loan 2
					,'Loan 2 Type' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN CASE WHEN fn.Loans.LoanSeqNum = 2 THEN opr.MMSLoans.Description END ELSE CASE WHEN fn.Loans.LoanSeqNum = 2 THEN opr.MMSLoans.Description END END
					,'Loan 2 Status' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN CASE WHEN fn.Loans.LoanSeqNum = 2 THEN fn.Loans.LoanStatus END ELSE CASE WHEN fn.Loans.LoanSeqNum = 2 THEN fn.Loans.LoanStatus END END
					--Date on which the loan was paid off
					--kk Converted datetime to date on February 14, 2022
					,'Date Paid' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN CONVERT(date, #LastPayment.LastPaymentDate) ELSE CONVERT(date, #LastPayment.LastPaymentDate) END
					--The last payment amount from the student
					,'Last Payment Amount' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN #LastPayment.LastPaymentAmt ELSE #LastPayment.LastPaymentAmt END
					--Of the last payment amount, how much was applied to Principal Balance
					,'Amount Applied to Principal Balance' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN CASE WHEN #PrincipalBalance.Principal IS NULL THEN 0 ELSE #PrincipalBalance.Principal END ELSE CASE WHEN #PrincipalBalance.Principal IS NULL THEN 0 ELSE #PrincipalBalance.Principal END END  
					--Of the last payment amount, how much was applied to Interest owed
					,'Amount Applied to Interest' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN CASE WHEN #Interest.Interest IS NULL THEN 0 ELSE #Interest.Interest END ELSE CASE WHEN #Interest.Interest IS NULL THEN 0 ELSE #Interest.Interest END END   
					--Shows the amount borrowed - Principal
					,'Total Principal Borrowed' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN fn.Loans.LoanAmt ELSE fn.Loans.LoanAmt END 
					--Shows the total interest that is expected to pay through the life of the loan - Interest
					,'Total Interest' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN fn.Loans.ProjectedInterest ELSE fn.Loans.ProjectedInterest END 
					--Shows only the total interest the borrower paid on the loan
					,'Total Interest Paid' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN #InterestPaid.Interest ELSE #InterestPaid.Interest END
					--Shows or calculates a percentage of the interest paid in comparison to the principal borrowed
					--Note: Name of the column was changed from % of Combined Interest Paid to % of Total Interest Paid. The formula for calculating the column was also changed from (Total Interest Paid/Total Principal Borrowed)*100 to (Total Interest Paid/Total Interest)*100. These changes were made on 2nd February, 2022 as per Ofelia's request.
					--kk Formatted the values to 2 decimal places on February 14, 2022
					,'% of Total Interest Paid' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN CASE WHEN fn.Loans.LoanAmt = 0.00 THEN '0.00' ELSE CONVERT(decimal(9,2),(#InterestPaid.Interest/ fn.Loans.ProjectedInterest))*100 END ELSE CASE WHEN fn.Loans.LoanAmt = 0.00 THEN '0.00' ELSE CONVERT(decimal(9,2),(#InterestPaid.Interest/ fn.Loans.ProjectedInterest))*100 END END
					--Includes all the late charges paid through the life of the loan
					,'Total Late Charges Paid' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN #LateCharges.LateFee ELSE #LateCharges.LateFee END
					--How many months it took the student to pay off the loan
					,'Paid Off In # Months' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN #DateDifference.DateDif ELSE #DateDifference.DateDif END
					,'Paid Off In # Years' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN #DateDifferenceYear.NoOfYears ELSE #DateDifferenceYear.NoOfYears END
					--Returns what the interest rate was when at the time when the loan(s) was paid off
					,'Last Interest Rate' = CASE WHEN (((fn.LoanCurrState.LoanItemID = 10) AND (fn.LoanCurrState.LoanItemAmt <= 0)) OR (fn.Loans.PayFlag = 'X')) THEN CASE WHEN #LastInterest.InterestRate IS NULL THEN 0 ELSE #LastInterest.InterestRate END ELSE CASE WHEN #LastInterest.InterestRate IS NULL THEN 0 ELSE #LastInterest.InterestRate END END
		--Changed FULL OUTER JOIN statements to LEFT JOIN on February 22, 2022			
		FROM fn.LoanCurrState 
		INNER JOIN fn.Loans					ON fn.LoanCurrState.LoanID = fn.Loans.LoanID 
		INNER JOIN act.UserInfo				ON fn.Loans.UserId = act.UserInfo.UserID 
		INNER JOIN fn.LoanPaymentApply		ON fn.LoanPaymentApply.LoanID = fn.Loans.LoanID	
		INNER JOIN opr.Institution			ON act.UserInfo.InstitutionID = opr.Institution.InstitutionID
		INNER JOIN opr.MMSLoans				ON fn.Loans.MMSLoanID = opr.MMSLoans.MMSLoanID
		INNER JOIN #LastPayment				ON fn.LoanCurrState.LoanID = #LastPayment.LoanID
		LEFT JOIN #PrincipalBalance			ON fn.LoanCurrState.LoanID = #PrincipalBalance.LoanID
		LEFT JOIN #Interest					ON fn.LoanCurrState.LoanID = #Interest.LoanID
		INNER JOIN #InterestPaid			ON fn.LoanCurrState.LoanID = #InterestPaid.LoanID
		INNER JOIN #LateCharges				ON fn.LoanCurrState.LoanID = #LateCharges.LoanID
		INNER JOIN #DateDifference			ON fn.LoanCurrState.LoanID = #DateDifference.LoanID
		INNER JOIN #DateDifferenceYear		ON fn.LoanCurrState.LoanID = #DateDifferenceYear.LoanID
		LEFT JOIN #LastInterest				ON fn.LoanCurrState.LoanID = #LastInterest.LoanID
		INNER JOIN #GetLoanDate				ON fn.LoanCurrState.LoanID = #GetLoanDate.LoanID
--msh Why do you filter on PaymentDate?
--kk Removed filter on February 23, 2022
		--Grouping all the records by all the columns for the final report
		GROUP BY 
			fn.LoanCurrState.LoanItemID,
			fn.LoanCurrState.LoanItemAmt,
			fn.Loans.PayFlag,
			act.UserInfo.UserID,
			rtrim(act.UserInfo.LastName) + ', ' + rtrim(act.UserInfo.FirstName),
			opr.Institution.InstitutionName,
			fn.Loans.LoanSeqNum,
			fn.Loans.LoanApprovedDate,
			opr.MMSLoans.Description,
			fn.Loans.LoanStatus,
			#LastPayment.LastPaymentDate,
			#LastPayment.LastPaymentAmt,
			#PrincipalBalance.Principal,
			#Interest.Interest,
			fn.Loans.LoanAmt,
			fn.Loans.ProjectedInterest,
			#InterestPaid.Interest,
			#LateCharges.LateFee,
			#DateDifference.DateDif,
			#DateDifferenceYear.NoOfYears,
			#LastInterest.InterestRate,
			#GetLoanDate.LoanDate
		--Ordering the records by Full Name of the student
		ORDER BY 'Name'
END

--msh How do you identify that the loan was paid in full? 
--msh what if the loan balance is $0.01; what if principal balan
--kk Used Temp Table #PaidOffLoans to get the fully paid off loans on February 23, 2022

GO

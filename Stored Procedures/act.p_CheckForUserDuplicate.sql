SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [act].[p_CheckForUserDuplicate]
	-- Add the parameters for the stored procedure here
	@FirstName  varchar(50) ,
	@MiddleInitial  varchar(10)  = NULL,
	@LastName  varchar(50) ,
	@Email  varchar(100),
	@SSNumber varchar(100) ,
	@LOEmail varchar(100),
	@MMSAdminEmail varchar(100),
	@InstitutionID int
AS
BEGIN
-- =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 07-09-2014
-- Description:	looking for a duplicate student
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			

			--set @MMSAdminEmail = 'svatasoiu@mms.org'

			--Begin code
			--check for duplicate on SSN
			DECLARE @MemUniqID varchar(255)
			DECLARE @body varchar(4000)
			DECLARE @FullName varchar(255)
			DECLARE @ExpireDateTime datetime
			DECLARE @UserIdentity int	
			declare @profile varchar(100)
			set @profile ='CEFUND'
				
			declare @subj varchar(100)
			declare @emailId int
			declare @counter int

			declare @ExistingUserId int
			declare @ExistingFirstName varchar(100)
			declare @ExistingLastName varchar(100)
			declare @ExistingInstitutionId int
			declare @ExistingInstitutionName varchar(100)
			declare @ProposedInstitutionName varchar(100)
			declare @ExistingEmail varchar(100)
			declare @LOFirstName varchar(100)
			declare @LOLastName varchar(100)
			


			OPEN SYMMETRIC KEY SLAPSymKey
				DECRYPTION BY CERTIFICATE SLAPCert	

			set @counter = (SELECT     COUNT(u.UserID) AS TotalCount
							FROM         act.UserInfo u
							WHERE     u.SSNHashed = dbo.HashData(@SSNumber))
			if (@counter >0)
			begin --
				--SSN duplicate found
				set @counter = (SELECT     COUNT(u.UserID) AS TotalCount
							FROM         act.UserInfo u
							WHERE   u.SSNHashed = dbo.HashData(@SSNumber)
									and u.LastName = @LastName
									and u.InstitutionID = @InstitutionID)
				if (@counter >0)
				begin --
					-- SSN match, LastName match, School match
					SELECT -100 ERRORCODE, 'We found a possible duplicate account.<br/>Please try to lookup the student by name and assign him a second loan or contact the administrator of the C &amp; E Fund at <a mailto:"' + @MMSAdminEmail + '">' + @MMSAdminEmail + '</a>.<br/>' ERRORMESSAGE
				end
				else
				begin
					-- get LO info
					SELECT  @LOLastName = u.LastName,
							@LOFirstName = u.FirstName,
							@ProposedInstitutionName = i.InstitutionName
					FROM      act.UserInfo AS u INNER JOIN
							opr.Institution AS i ON u.InstitutionID = i.InstitutionID
					WHERE   u.Email = @LOEmail

					-- check for name changed
					set @counter = (SELECT     COUNT(u.UserID) AS TotalCount
								FROM      act.UserInfo u
								WHERE   u.SSNHashed = dbo.HashData(@SSNumber)
										and u.LastName <> @LastName
										and u.InstitutionID = @InstitutionID)
					if (@counter >0)
					begin --
						-- SSN match, LastName not match, School match
						-- send email notification to MMS admin
						set @subj= 'SLAP - Potential name changed for student'

						SELECT  @ExistingUserId = u.UserID ,
								@ExistingLastName = u.LastName,
								@ExistingFirstName = u.FirstName,
								@ExistingEmail = u.Email,
								@ExistingInstitutionName = i.InstitutionName
						FROM    act.UserInfo AS u INNER JOIN
							opr.Institution AS i ON u.InstitutionID = i.InstitutionID
						WHERE   u.SSNHashed = dbo.HashData(@SSNumber)
								--and u.LastName <> @LastName
								--and u.InstitutionID = @InstitutionID

						set @body = 'Dear ' + 'CELoan Admin' + ',' + Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'We found a possible name change for an existing account. ' + '<br/>'
									+ 'The following information was submitted:<br/>'
									+ '<br/>First Name    = ' + isnull(@FirstName,'')
									+ '<br/>Last Name     = ' + isnull(@LastName,'')
									+ '<br/>Email         = ' + isnull(@Email,'')
									+ '<br/>School        = ' + isnull(@ProposedInstitutionName,'')
									+ Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'The proposed student matches the SSN for the existing account:' + '<br/>'
									+ '<br/>AccountId     = ' + ltrim(rtrim(convert(varchar(20),isnull(@ExistingUserId,-1))))
									+ '<br/>First Name    = ' + isnull(@ExistingFirstName,'')
									+ '<br/>Last Name     = ' + isnull(@ExistingLastName,'')
									+ '<br/>Email         = ' + isnull(@ExistingEmail,'')
									+ '<br/>School        = ' + isnull(@ExistingInstitutionName,'')
									+ Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'Please investigate the potential SSN duplicate and instruct the Loan Officer ' + @LOFirstName + ' ' + @LOLastName + ' (' + @LOEmail + ') from ' + @ProposedInstitutionName + ' on how to proceed.' + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'Thank You.'
									+ Char(10) +Char(13) + '<br/>'
							--select EmailTo=@MMSAdminEmail
							--profile = @profile,
							--Subject = @subj,
							--Body = @body
							--/*
							exec opr.p_AddEmailLogSP @EmailTo = @MMSAdminEmail
												,@EmailCC = null
												,@EmailBCC = null
												,@EmailProfile = @profile
												,@Subject = @subj
												,@Body = @body
												,@BodyFormat = 'HTML'
												,@AttachementLink = null
												,@SentOn = null
												,@InsertedBy = 'act.p_CheckForUserDuplicate'
												,@EmailId = @EmailId  output


							exec msdb.dbo.sp_send_dbmail 
								@recipients = @MMSAdminEmail
								,@profile_name = @profile
								,@subject = @subj
								,@body = @body		
								,@body_format = 'HTML' 

							update [dbo].[mms_Email]
							set MailSent = getdate()
							where Id = @emailId

							--send notification to LO
							set @body = 'Dear ' + @LOFirstName + ' ' + @LOLastName  + ',' + Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'The information you tried to submit for a new student may be matching an existing account (possible name changed)<br/>'
									+ '<br/>First Name    = ' + isnull(@FirstName,'')
									+ '<br/>Last Name     = ' + isnull(@LastName,'')
									+ '<br/>Email         = ' + isnull(@Email,'')
									+ '<br/>School        = ' + isnull(@ProposedInstitutionName,'')
									+ Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'The C&E Loan Fund Administrator was notified and he will contact you regarding on how to proceed.' + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'Thank You.'
									+ Char(10) +Char(13) + '<br/>'
							--select EmailTo=@MMSAdminEmail
							--profile = @profile,
							--Subject = @subj,
							--Body = @body
							--/*
							exec opr.p_AddEmailLogSP @EmailTo = @LOEmail
												,@EmailCC = null
												,@EmailBCC = null
												,@EmailProfile = @profile
												,@Subject = @subj
												,@Body = @body
												,@BodyFormat = 'HTML'
												,@AttachementLink = null
												,@SentOn = null
												,@InsertedBy = 'act.p_CheckForUserDuplicate'
												,@EmailId = @EmailId  output


							exec msdb.dbo.sp_send_dbmail 
								@recipients = @LOEmail
								,@profile_name = @profile
								,@subject = @subj
								,@body = @body		
								,@body_format = 'HTML' 

							update [dbo].[mms_Email]
							set MailSent = getdate()
							where Id = @emailId

						SELECT -200 ERRORCODE, 'The account for the new student was not created.<br/>We found a possible name change for an existing account.<br/>Please contact the administrator of the C &amp; E Fund at <a mailto:"' + @MMSAdminEmail + '">' + @MMSAdminEmail + '</a> for instructions on how to proceed.<br/>' ERRORMESSAGE
					end
					else
					begin
						-- SSN match, LastName not match, School not match
						-- send email notification to MMS admin
						set @subj= 'SLAP - Potential existing account for proposed student'

						SELECT  @ExistingUserId = u.UserID ,
								@ExistingLastName = u.LastName,
								@ExistingFirstName = u.FirstName,
								@ExistingEmail = u.Email,
								@ExistingInstitutionName = i.InstitutionName
						FROM    act.UserInfo AS u INNER JOIN
							opr.Institution AS i ON u.InstitutionID = i.InstitutionID
						WHERE   u.SSNHashed = dbo.HashData(@SSNumber)
								--and u.LastName <> @LastName
								--and u.InstitutionID = @InstitutionID

						set @body = 'Dear ' + 'CELoan Admin' + ',' + Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'We found a mismatch (duplicate SSN) between an existing account and a proposed student. ' + '<br/>'
									+ 'The following information was submitted:<br/>'
									+ '<br/>First Name    = ' + isnull(@FirstName,'')
									+ '<br/>Last Name     = ' + isnull(@LastName,'')
									+ '<br/>Email         = ' + isnull(@Email,'')
									+ '<br/>School        = ' + isnull(@ProposedInstitutionName,'')
									+ Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'The proposed student matches the SSN for the existing account:' + '<br/>'
									+ '<br/>AccountId     = ' + ltrim(rtrim(convert(varchar(20),isnull(@ExistingUserId,-1))))
									+ '<br/>First Name    = ' + isnull(@ExistingFirstName,'')
									+ '<br/>Last Name     = ' + isnull(@ExistingLastName,'')
									+ '<br/>Email         = ' + isnull(@ExistingEmail,'')
									+ '<br/>School        = ' + isnull(@ExistingInstitutionName,'')
									+ Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'Please investigate the potential SSN duplicate and instruct the Loan Officer ' + @LOFirstName + ' ' + @LOLastName + ' (' + @LOEmail + ') from ' + @ProposedInstitutionName + ' on how to proceed.' + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'Thank You.'
									+ Char(10) +Char(13) + '<br/>'
							--select EmailTo=@MMSAdminEmail
							--profile = @profile,
							--Subject = @subj,
							--Body = @body
							--/*
							exec opr.p_AddEmailLogSP @EmailTo = @MMSAdminEmail
												,@EmailCC = null
												,@EmailBCC = null
												,@EmailProfile = @profile
												,@Subject = @subj
												,@Body = @body
												,@BodyFormat = 'HTML'
												,@AttachementLink = null
												,@SentOn = null
												,@InsertedBy = 'act.p_CheckForUserDuplicate'
												,@EmailId = @EmailId  output


							exec msdb.dbo.sp_send_dbmail 
								@recipients = @MMSAdminEmail
								,@profile_name = @profile
								,@subject = @subj
								,@body = @body		
								,@body_format = 'HTML' 

							update [dbo].[mms_Email]
							set MailSent = getdate()
							where Id = @emailId

							--send notification to LO
							set @body = 'Dear ' + @LOFirstName + ' ' + @LOLastName  + ',' + Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'The information you tried to submit for a new student may be matching an existing account (possible name changed)<br/>'
									+ '<br/>First Name    = ' + isnull(@FirstName,'')
									+ '<br/>Last Name     = ' + isnull(@LastName,'')
									+ '<br/>Email         = ' + isnull(@Email,'')
									+ '<br/>School        = ' + isnull(@ProposedInstitutionName,'')
									+ Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'The C&E Loan Fund Administrator was notified and he will contact you regarding on how to proceed.' + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ Char(10) +Char(13) + '<br/>'
									+ 'Thank You.'
									+ Char(10) +Char(13) + '<br/>'
							--select EmailTo=@MMSAdminEmail
							--profile = @profile,
							--Subject = @subj,
							--Body = @body
							--/*
							exec opr.p_AddEmailLogSP @EmailTo = @LOEmail
												,@EmailCC = null
												,@EmailBCC = null
												,@EmailProfile = @profile
												,@Subject = @subj
												,@Body = @body
												,@BodyFormat = 'HTML'
												,@AttachementLink = null
												,@SentOn = null
												,@InsertedBy = 'act.p_CheckForUserDuplicate'
												,@EmailId = @EmailId  output


							exec msdb.dbo.sp_send_dbmail 
								@recipients = @LOEmail
								,@profile_name = @profile
								,@subject = @subj
								,@body = @body		
								,@body_format = 'HTML' 

							update [dbo].[mms_Email]
							set MailSent = getdate()
							where Id = @emailId
						SELECT -300 ERRORCODE, 'The account for the new student was not created.<br/>We found a possible match with an existing account.<br/>Please contact the administrator of the C &amp; E Fund at <a mailto:"' + @MMSAdminEmail + '">' + @MMSAdminEmail + '</a> for instructions on how to proceed.<br/>' ERRORMESSAGE
					end
				end
			end
			else
			begin
				-- no ssn duplicate
				SELECT 0 ERRORCODE, 'No duplicate student found' ERRORMESSAGE
			end
			--End code

		commit tran

	end try
	begin catch
		--if a transaction was started, rollback
		if @@trancount > 0
		begin
			rollback tran
		end
			
		--log error in table
		exec dbo.p_DBA_LogError

		--raise error to front end
		declare @errProc nvarchar(126),
				@errLine int,
				@errMsg  nvarchar(max)
		select  @errProc = error_procedure(),
				@errLine = error_line(),
				@errMsg  = error_message()
		raiserror('Proc: %s - Line: %d - Error: %s', 12 ,1 ,@errProc, @errLine, @errMsg)
		return(-1)
	end catch

END
GO

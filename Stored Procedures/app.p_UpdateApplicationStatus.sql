SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [app].[p_UpdateApplicationStatus]
	-- Add the parameters for the stored procedure here
	@ApplicationID int,
	@CurrentStatus int,
	@NewStatus int
AS
BEGIN
/* =============================================
-- Author:		Sorin Vatasoiu
-- Create date: 4/1/2014
-- Description:	update application status and send emails if needed

/* test data

 [app].[p_UpdateApplicationStatus] 77,220,230

*/
-- =============================================
*/
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	begin try

		begin tran
			declare @MMSAdminEmail varchar(100)
			set @MMSAdminEmail = 'Cefund@mms.org'
			--Begin code
			-- analize the status tranzition and set the corresponding lock flag
			-- and sent the required emails
				declare @profile varchar(100)
				set @profile ='CEFUND'
				
				declare @body varchar(7000)
				declare @subj varchar(100)
				declare @emailId int

				declare @urlPublic varchar(100)
				set @urlPublic = dbo.fnGetWebLinkForEnvironment(0) 
				declare @urlAdmin varchar(100)
				set @urlAdmin = dbo.fnGetWebLinkForEnvironment(1) 

				-- get info for emails
				declare @StLastName varchar(50),
						@StFirstName varchar(50),
						@StEmail varchar(100),
						@StTitle varchar(50),
						@StMiddleInitial varchar(10),
						@LoLastName varchar(50),
						@LoFirstName varchar(50),
						@LoEmail varchar(100),
						@LoTitle varchar(50),
						@LoMiddleInitial varchar(10),
						@AppUid varchar(100)

				SELECT  @StFirstName = st.FirstName , 
						@StTitle = st.Title  , 
						@StEmail = st.Email , 
						@StMiddleInitial = st.MiddleInitial  , 
						@StLastName =st.LastName , 
						@LoFirstName = lo.FirstName, 
						@LoMiddleInitial = lo.MiddleInitial, 
						@LoLastName = lo.LastName, 
						@LoEmail = lo.Email + ';' + isnull(lo.SchoolNotificationEmail,''), 
						@LoTitle = lo.Title , 
						@AppUid = appl.Uniqueidentifier 
				FROM         act.UserInfo AS st INNER JOIN
									  app.Application appl ON st.UserID = appl.UserID INNER JOIN
									  act.UserInfo AS lo ON appl.OfficerId = lo.UserID
				WHERE     (appl.ApplicationID = @ApplicationID)

				UPDATE [app].[Application]
				SET 
					[ApplStatus] = @NewStatus,
					[DateUpdated] = getdate()
				WHERE ApplicationID = @ApplicationID	
			
			/* === start block ============================================================== */
				if (@CurrentStatus in (200,210) and @NewStatus = 220)
				begin 
					/*
					student approved the application
					lock the app for student
					send email to loan officer
					*/
					--select 'debug 1'
					UPDATE [app].[Application]
					SET 
						[LockedForStudent] = 1,
						[LockedForOfficer] =0,
						[LockedForAdmin] =0,
						[DateUpdated] = getdate()
					WHERE ApplicationID = @ApplicationID





					set @subj= 'MMS student loan application ready for review'

					set @body = 'Dear ' + @LoFirstName + ' ' + @LoLastName + ','
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'An application for loan from the MMS C&E Fund has been submitted and is ready for your review. ' + '<br/>'
								+ '<a href="' + @urlPublic + '/Application/FillApplication.aspx?uid=' + @AppUid + '">Please click here to logon and review this application.</a>' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
 								+ 'Please contact Ofelia Teixeira at <a mailto:"cefund@mms.org">cefund@mms.org</a> should you have any questions.'
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Thank you.'



					exec opr.p_AddEmailLogSP @EmailTo = @LoEmail
							   ,@EmailCC = null
							   ,@EmailBCC = null
							   ,@EmailProfile = @profile
							   ,@Subject = @subj
							   ,@Body = @body
							   ,@BodyFormat = 'HTML'
							   ,@AttachementLink = null
							   ,@SentOn = null
							   ,@InsertedBy = 'auto'
								,@EmailId = @EmailId  output



					exec msdb.dbo.sp_send_dbmail 
						@recipients = @LoEmail
						,@profile_name = @profile
						,@subject = @subj
						,@body = @body		
						,@body_format = 'HTML' 

					update [dbo].[mms_Email]
					set MailSent = getdate()
					where Id = @emailId

				end
			/* === end block === */
		
			/* === start block ============================================================== */
				if (@CurrentStatus in (220) and @NewStatus = 230)
				begin 
					/*
					loan officer approved the application
					lock the app for student
					lock the app for loan officer
					send email to mms admin
					*/
					--select 'debug 1'
					UPDATE [app].[Application]
					SET 
						[LockedForStudent] = 1,
						[LockedForOfficer] =1,
						[LockedForAdmin] =0,
						[DateUpdated] = getdate()
					WHERE ApplicationID = @ApplicationID


					set @subj= 'MMS student loan application ready for review'

					set @body = 'Dear ' + 'CELoan Admin' + ',' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'An application for loan from the MMS C&E Fund has been submitted and is ready for your review. ' + '<br/>'
								+ '<a href="'+ @urlAdmin + '/Applications/APApplication.aspx?auid=' + @AppUid  + '">Please click here to logon and review this application</a>' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Thank you.'
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
--select EmailTo=@MMSAdminEmail,
--profile = @profile,
--Subject = @subj,
--Body = @body
					exec opr.p_AddEmailLogSP @EmailTo = @MMSAdminEmail
							   ,@EmailCC = null
							   ,@EmailBCC = null
							   ,@EmailProfile = @profile
							   ,@Subject = @subj
							   ,@Body = @body
							   ,@BodyFormat = 'HTML'
							   ,@AttachementLink = null
							   ,@SentOn = null
							   ,@InsertedBy = 'auto'
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
--select 'LO approved 220 => 230'
				end
			/* === end block === */

			/* === start block ============================================================== */
				if (@CurrentStatus in (220) and @NewStatus = 210)
				begin 
					/*
					loan officer rejected the application
					unlock the app for student
					unlock the app for loan officer
					send email to student
					*/
					--select 'debug 1'
					UPDATE [app].[Application]
					SET 
						[LockedForStudent] = 0,
						[LockedForOfficer] =0,
						[LockedForAdmin] =0,
						[DateUpdated] = getdate()
					WHERE ApplicationID = @ApplicationID

					set @subj= 'MMS student loan application ready for review'

					set @body = 'Dear ' + @StFirstName + ' ' + @StLastName + ',' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Your application for loan from the MMS C&E Fund need to be reviewed.' + '<br/>'
								+ '<a href="'+ @urlPublic + '/Application/FillApplication.aspx?uid=' + @AppUid  + '">Please click here to logon and review this application</a>' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
 								+ 'Please contact your financial aid office should you have any questions regarding this email or loans from the MMS Charitable and Educational Fund.'
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Thank you.'
								+ Char(10) +Char(13) + '<br/>'


					exec opr.p_AddEmailLogSP @EmailTo = @StEmail
							   ,@EmailCC = null
							   ,@EmailBCC = null
							   ,@EmailProfile = @profile
							   ,@Subject = @subj
							   ,@Body = @body
							   ,@BodyFormat = 'HTML'
							   ,@AttachementLink = null
							   ,@SentOn = null
							   ,@InsertedBy = 'auto'
								,@EmailId = @EmailId  output

--select @LoEmail,@subj,@body
					exec msdb.dbo.sp_send_dbmail 
						@recipients = @StEmail
						,@profile_name = @profile
						,@subject = @subj
						,@body = @body		
						,@body_format = 'HTML' 


					update [dbo].[mms_Email]
					set MailSent = getdate()
					where Id = @emailId
				end
			/* === end block === */

			/* === start block ============================================================== */
				if (@CurrentStatus in (230) and @NewStatus = 260)
				begin 
					/*
					mms admin rejected the application
					lock the app for student
					lock the app for loan officer
					lock the app for loan mms admin
					send email to student, loan officer
					*/
					--select 'debug 1'
					UPDATE [app].[Application]
					SET 
						[LoanApprovedFlag] =0,
						[LockedForStudent] = 1,
						[LockedForOfficer] =1,
						[LockedForAdmin] =1,
						[DateUpdated] = getdate()
					WHERE ApplicationID = @ApplicationID

					set @subj= 'MMS student loan application was rejected'

					set @body = 'Dear ' + @StFirstName + ' ' + @StLastName + ',' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Your application for loan from the MMS C&E Fund was rejected.' + '<br/>'
								+ '<a href="'+ @urlPublic + '/Application/FillApplication.aspx?uid=' + @AppUid  + '">Please click here to logon and review this application</a>' 
								+ Char(10) +Char(13) + '<br/>'
 								+ 'Please contact your financial aid office should you have any questions regarding this email or loans from the MMS Charitable and Educational Fund.'
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Thank you.'
								+ Char(10) +Char(13) + '<br/>'

					exec opr.p_AddEmailLogSP @EmailTo = @StEmail
							   ,@EmailCC = null
							   ,@EmailBCC = null
							   ,@EmailProfile = @profile
							   ,@Subject = @subj
							   ,@Body = @body
							   ,@BodyFormat = 'HTML'
							   ,@AttachementLink = null
							   ,@SentOn = null
							   ,@InsertedBy = 'auto'
								,@EmailId = @EmailId  output

--select @LoEmail,@subj,@body
					exec msdb.dbo.sp_send_dbmail 
						@recipients =  @StEmail
						,@profile_name = @profile
						,@subject = @subj
						,@body = @body		
						,@body_format = 'HTML' 


					update [dbo].[mms_Email]
					set MailSent = getdate()
					where Id = @emailId
					
					end
			/* === end block === */

			/* === start block ============================================================== */
				if (@CurrentStatus in (230,290) and @NewStatus = 210)
				begin 
					/*
					mms admin send the application back for review
					unlock the app for student
					unlock the app for loan officer
					unlock the app for loan mms admin
					send email to student, loan officer
					*/
					--select 'debug 1'
					UPDATE [app].[Application]
					SET 
						[LockedForStudent] = 0,
						[LockedForOfficer] =0,
						[LockedForAdmin] =0,
						[DateUpdated] = getdate()
					WHERE ApplicationID = @ApplicationID

					set @subj= 'MMS student loan application ready for review'

					set @body = 'Dear ' + @StFirstName + ' ' + @StLastName + ',' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Your application for loan from the MMS C&E Fund need to be reviewed.' + '<br/>'
								+ '<a href="'+  @urlPublic + '/Application/FillApplication.aspx?uid=' + @AppUid  + '">Please click here to logon and review this application</a>' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
 								+ 'Please contact your financial aid office should you have any questions regarding this email or loans from the MMS Charitable and Educational Fund.'
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Thank you.'
								+ Char(10) +Char(13) + '<br/>'

					exec opr.p_AddEmailLogSP @EmailTo = @StEmail
							   ,@EmailCC = null
							   ,@EmailBCC = null
							   ,@EmailProfile = @profile
							   ,@Subject = @subj
							   ,@Body = @body
							   ,@BodyFormat = 'HTML'
							   ,@AttachementLink = null
							   ,@SentOn = null
							   ,@InsertedBy = 'auto'
								,@EmailId = @EmailId  output

--select @LoEmail,@subj,@body
					exec msdb.dbo.sp_send_dbmail 
						@recipients =  @StEmail
						,@profile_name = @profile
						,@subject = @subj
						,@body = @body		
						,@body_format = 'HTML' 


					update [dbo].[mms_Email]
					set MailSent = getdate()
					where Id = @emailId
				end
			/* === end block === */


			/* === start block ============================================================== */
				if (@CurrentStatus in (200,210,220,230) and @NewStatus = 290)
				begin 
					/*
					mms admin suspended the application 
					lock the app for student
					lock the app for loan officer
					lock the app for loan mms admin
					send email to student, loan officer
					*/
					--select 'debug 1'
					UPDATE [app].[Application]
					SET 
						[LockedForStudent] = 1,
						[LockedForOfficer] = 1,
						[LockedForAdmin] = 1,
						[DateUpdated] = getdate()
					WHERE ApplicationID = @ApplicationID

					set @subj= 'MMS Admin suspended the application '

					set @body = 'Dear ' + @StFirstName + ' ' + @StLastName + ',' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'The following application is suspended until further notice..' + '<br/>'
								+ 'Please use the following link to view the application.' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ @urlPublic + '/Application/FillApplication.aspx?uid=' + @AppUid  
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
 								+ 'Please contact Customer Service should you have any additional questions.  They may be reached from 1-800-843-6356.'
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Thank you!'
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'

					exec opr.p_AddEmailLogSP @EmailTo = @StEmail
							   ,@EmailCC = null
							   ,@EmailBCC = null
							   ,@EmailProfile = @profile
							   ,@Subject = @subj
							   ,@Body = @body
							   ,@BodyFormat = 'HTML'
							   ,@AttachementLink = null
							   ,@SentOn = null
							   ,@InsertedBy = 'auto'
								,@EmailId = @EmailId  output

--select @LoEmail,@subj,@body
					exec msdb.dbo.sp_send_dbmail 
						@recipients =  @StEmail
						,@profile_name = @profile
						,@subject = @subj
						,@body = @body		
						,@body_format = 'HTML' 

					update [dbo].[mms_Email]
					set MailSent = getdate()
					where Id = @emailId
				end
			/* === end block === */

			/* === start block ============================================================== */
				if (@CurrentStatus in (230) and @NewStatus = 240)
				begin 
					/*
					mms admin application is ready for face to face meeting
					lock the app for student
					lock the app for loan officer
					unlock the app for loan mms admin
					send email to admin to set the face to face
					*/
					--select 'debug 1'
					UPDATE [app].[Application]
					SET 
						[LockedForStudent] = 1,
						[LockedForOfficer] = 1,
						[LockedForAdmin] = 0,
						[DateUpdated] = getdate()
					WHERE ApplicationID = @ApplicationID


					set @subj= 'The following application is ready for a face to face meeting with the student'

					--send email to Student
					set @body = 'Dear ' + 'CELoan Admin' + ',' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Your following application is ready for a face to face meeting ,' + 
								+ '<a href="'+ @urlAdmin + '/Applications/APApplication.aspx?auid=' + @AppUid  + '">Please click here to logon and review this application</a>'  
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Thank you.'
								+ Char(10) +Char(13) + '<br/>'

					exec opr.p_AddEmailLogSP @EmailTo = @MMSAdminEmail
							   ,@EmailCC = null
							   ,@EmailBCC = null
							   ,@EmailProfile = @profile
							   ,@Subject = @subj
							   ,@Body = @body
							   ,@BodyFormat = 'HTML'
							   ,@AttachementLink = null
							   ,@SentOn = null
							   ,@InsertedBy = 'auto'
								,@EmailId = @EmailId  output

--select @LoEmail,@subj,@body
					exec msdb.dbo.sp_send_dbmail 
						@recipients =  @MMSAdminEmail
						,@profile_name = @profile
						,@subject = @subj
						,@body = @body		
						,@body_format = 'HTML' 

					update [dbo].[mms_Email]
					set MailSent = getdate()
					where Id = @emailId


				end
			/* === end block === */


			/* === start block ============================================================== */
				if (@CurrentStatus in (240) and @NewStatus = 250)
				begin 
					/*
					mms admin approved the application 
					lock the app for student
					lock the app for loan officer
					lock the app for loan mms admin
					send email to student, loan officer
					*/
					--select 'debug 1'
					UPDATE [app].[Application]
					SET 
						[LockedForStudent] = 1,
						[LockedForOfficer] = 1,
						[LockedForAdmin] = 1,
						[LoanApprovedFlag] = 1,
						[LoanApprovedDate] = getdate() ,
						[DateUpdated] = getdate()
					WHERE ApplicationID = @ApplicationID

					--create the loan from the application
					exec app.p_CreateLoanFromApplication @ApplicationID=@ApplicationID

					set @subj= 'MMS Admin approved the application '

					--send email to Student
					set @body = 'Dear ' + @StFirstName + ' ' + @StLastName + ',' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Your application for a loan from the Massachusetts Medical Society Charitable and Educational Fund has been approved. The financial aid office at your medical school will contact you to coordinate the final phase of the process and release of your funding. To logon and view your application,' + 
								+ '<a href="' +@urlPublic + '/Application/FillApplication.aspx?uid=' + @AppUid  + '">please click here</a>.' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Thank you.'
								+ Char(10) +Char(13) + '<br/>'

					exec opr.p_AddEmailLogSP @EmailTo = @StEmail
							   ,@EmailCC = null
							   ,@EmailBCC = null
							   ,@EmailProfile = @profile
							   ,@Subject = @subj
							   ,@Body = @body
							   ,@BodyFormat = 'HTML'
							   ,@AttachementLink = null
							   ,@SentOn = null
							   ,@InsertedBy = 'auto'
								,@EmailId = @EmailId  output

--select @LoEmail,@subj,@body
					exec msdb.dbo.sp_send_dbmail 
						@recipients =  @StEmail
						,@profile_name = @profile
						,@subject = @subj
						,@body = @body		
						,@body_format = 'HTML' 

					update [dbo].[mms_Email]
					set MailSent = getdate()
					where Id = @emailId

						--send email to LO
								set @body = 'Dear ' + @LoFirstName + ' ' + @LoLastName + ',' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'The following application for a loan from the Massachusetts Medical Society Charitable and Educational Fund has been approved.' + '<br/>'
								+ 'To logon and view your application <a href="' +@urlPublic + '/Application/FillApplication.aspx?uid=' + @AppUid + '">please click here.</a>' 
 								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
 								+ 'Please contact CE Fund at <a mailto:"cefund@mms.org">cefund@mms.org</a> if you encounter any logon difficulties or did not request this change.'
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Thank you.'
								+ Char(10) +Char(13) + '<br/>'



					exec opr.p_AddEmailLogSP @EmailTo = @LoEmail
							   ,@EmailCC = null
							   ,@EmailBCC = null
							   ,@EmailProfile = @profile
							   ,@Subject = @subj
							   ,@Body = @body
							   ,@BodyFormat = 'HTML'
							   ,@AttachementLink = null
							   ,@SentOn = null
							   ,@InsertedBy = 'auto'
								,@EmailId = @EmailId  output

--select @LoEmail,@subj,@body
					exec msdb.dbo.sp_send_dbmail 
						@recipients =  @LoEmail
						,@profile_name = @profile
						,@subject = @subj
						,@body = @body		
						,@body_format = 'HTML' 

					update [dbo].[mms_Email]
					set MailSent = getdate()
					where Id = @emailId

				end
			/* === end block === */

			/* === start block ============================================================== */
				if (@CurrentStatus in (199) and @NewStatus = 200)
				begin 
					/*
					loan officer proposed new application for existing student
					unlock the app for student
					unlock the app for loan officer
					unlock the app for loan mms admin
					send email to student
					*/
					--select 'debug 1'
					UPDATE [app].[Application]
					SET 
						[DateUpdated] = getdate()
					WHERE ApplicationID = @ApplicationID

					set @subj= 'MMS student loan application ready for review'


					set @body = 'Dear ' + @StFirstName + ' ' + @StLastName + ',' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Your application for loan from the MMS C&E Fund is ready to be reviewed.' + '<br/>'
								+ '<a href="'+  @urlPublic + '/Application/FillApplication.aspx?uid=' + @AppUid  + '">Please click here to logon and review this application</a>' 
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
 								+ 'Please contact your financial aid office should you have any questions regarding this email or loans from the MMS Charitable and Educational Fund.'
								+ Char(10) +Char(13) + '<br/>'
								+ Char(10) +Char(13) + '<br/>'
								+ 'Thank you.'
								+ Char(10) +Char(13) + '<br/>'


					exec opr.p_AddEmailLogSP @EmailTo = @StEmail
									   ,@EmailCC = null
									   ,@EmailBCC = null
									   ,@EmailProfile = @profile
									   ,@Subject = @subj
									   ,@Body = @body
									   ,@BodyFormat = 'HTML'
									   ,@AttachementLink = null
									   ,@SentOn = null
									   ,@InsertedBy = 'auto'
								,@EmailId = @EmailId  output

--select @LoEmail,@subj,@body
					exec msdb.dbo.sp_send_dbmail 
						@recipients =  @StEmail
						,@profile_name = @profile
						,@subject = @subj
						,@body = @body		
						,@body_format = 'HTML' 


					update [dbo].[mms_Email]
					set MailSent = getdate()
					where Id = @emailId

				end

						/* === end block === */
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
GRANT EXECUTE ON  [app].[p_UpdateApplicationStatus] TO [ExecSP]
GO

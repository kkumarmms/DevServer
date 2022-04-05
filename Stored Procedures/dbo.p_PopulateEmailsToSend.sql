SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[p_PopulateEmailsToSend]
as
/***
	Author: Msherman 
	Date:   2012/12/19
	Desc:  builds welcom and confirmation e-mails and populates mms_Email table to create a queue for e-mail blast
***/

set nocount on
begin try

  --*****************************************
  -- PROCESS WELCOME EMAILS
  --*****************************************

Begin Transaction

INSERT  [MadGex_Emails].[dbo].[mms_Email]
      ([Profile_Name]
      ,[recipients]
      ,[Copy_Recipients]
      ,[BCC_Recipients]
      ,[Subject]
      ,[Body]
      ,[Body_Format]
      --,[Attachments]
      )

   
 SELECT 
		[Profile_Name] = 'MadGex'
		,[sContactEmailAddress]
		,[Copy_Recipients] = null
		,[BCC_Recipients] = null
		,[Subject] = 'Welcome to the NEJM CareerCenter!'
		,[Body] = convert (varchar(max),'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<!-- Begin Mobile Viewport -->
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<!-- End Mobile Viewport -->
<title>Your Message Subject or Title</title>
<style type="text/css">
/***************************************************
		****************************************************
		MOBILE TARGETING
		****************************************************
		***************************************************/

		@media only screen and (max-device-width: 480px) {
/* Part one of controlling phone number linking for mobile. */
a[href^="tel"], a[href^="sms"] {
	text-decoration: none;
	color: blue; /* or whatever your want */
	pointer-events: none;
	cursor: default;
}
.mobile_link a[href^="tel"], .mobile_link a[href^="sms"] {
	text-decoration: default;
	color: #006892 !important;
	pointer-events: auto;
	cursor: default;
	font-weight: bold;
}
table[id=backgroundTable] {
	margin:10px;
	padding:0;
	width:320px !important;
	line-height: 100% !important;
}
table[id=NEJMPreferredIDTable] {
	margin-top: 80px;
	width:100% !important;
}
td[class=NEJMPreferredID] {
	background-image: url(''http://employer.nejmcareercenter.org/images/nejmID-preferred@2x.png'') !important;
	background-repeat:no-repeat;
!important;
	background-size: 182px 28px;
}
td[class=NEJMPreferredID] img {
	display: none;
}
td[class=NEJMCCID] {
	background-image: url(''http://employer.nejmcareercenter.org/images/nejmCareerCenter@2x.png'') !important;
	background-repeat:no-repeat;
!important;
	background-size: 234px 60px;
}
td[class=NEJMCCID] img {
	display:none;
}
}

		/* More Specific Targeting */

		@media only screen and (min-device-width: 768px) and (max-device-width: 1024px) {
/* You guessed it, ipad (tablets, smaller screens, etc) */
			/* repeating for the ipad */
	a[href^="tel"], a[href^="sms"] {
	text-decoration: none;
	color: #006892!important; /* or whatever your want */
	pointer-events: none;
	cursor: default;
}
.mobile_link a[href^="tel"], .mobile_link a[href^="sms"] {
	text-decoration: none;
	color: #006892 !important;
	pointer-events: auto;
	cursor: default;
}
}
</style>

<!-- Targeting Windows Mobile -->
<!--[if IEMobile 7]>
	<style type="text/css">
	
	</style>
	<![endif]-->

<!-- ***********************************************
	****************************************************
	END MOBILE TARGETING
	****************************************************
	************************************************ -->

<!--[if gte mso 9]>
		<style>
		/* Target Outlook 2007 and 2010 */
		</style>
	<![endif]-->
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" style="-webkit-font-smoothing: antialiased;width:100% !important;background:#ffffff;-webkit-text-size-adjust:none;">
<style type="text/css">
a { color: #006892 !important; text-decoration: none !important;}
a:hover {text-decoration:underline;}
</style>
<table cellpadding="0" cellspacing="0" border="0" id="backgroundTable" style="width: 520px; line-height: 100% !important; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; margin-top: 10px; margin-right: 10px; margin-bottom: 10px; margin-left: 10px; padding-top: 0; padding-right: 0; padding-bottom: 0; padding-left: 0;">
	<tr>
		<td valign="bottom" class="NEJMCCID" style="padding-top: 0; padding-right: 15px; padding-bottom: 15px; padding-left: 15px;"><a href="http://www.nejmcareercenter.org/" target =" _blank="" title="Find Physician Jobs at the NEJM CareerCenter" style="color: #006892; text-decoration: none; font-weight: bold;"><img src="http://employer.nejmcareercenter.org/images/nejmCareerCenter-60px.gif" alt="Visit the NEJM CareerCenter" title="Visit the NEJM CareerCenter" width="234" height="60" border="0" style="outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; border-top-style: none; border-right-style: none; border-bottom-style: none; border-left-style: none;" /></a>
			<table id="NEJMPreferredIDTable" border="0" align="right" cellpadding="0" cellspacing="0" style="border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 186px;">
				<tr>
					<td class="NEJMPreferredID" style="padding-top: 30px;"><a href="http://www.nejm.org/" target="_blank" title="Visit NEJM.org" style="color: #006892; text-decoration: none; font-weight: bold;"><img src="http://employer.nejmcareercenter.org/images/nejmID-preferred-28px.gif" alt="Visit NEJM.org" title="Visit NEJM.org" width="182" height="28" border="0" style="outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; border-top-style: none; border-right-style: none; border-bottom-style: none; border-left-style: none;" /></a></td>
				</tr>
			</table></td>
	</tr>
	<tr>
		<td class="content" valign="top" style="padding-top: 15px; padding-right: 15px; padding-bottom: 15px; padding-left: 15px; border-top-style: solid; border-right-color: #CCCCCC; border-bottom-color: #CCCCCC; border-left-color: #CCCCCC; border-top-color: #CCCCCC; border-right-style: solid; border-bottom-style: solid; border-left-style: solid; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px;"><h1 style="color: black !important; font-size: 18px; line-height: 23px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 0; padding-bottom: 24px; text-align: center;" align="center">Welcome to <a href="http://www.nejmcareercenter.org" target="_blank" title="Find Physician Jobs at the NEJM CareerCenter" style="color: #006892 !important; text-decoration: none; font-weight: bold;">NEJM CareerCenter</a>!</h1>
			<h2 style="color: black !important; font-size: 14px; line-height: 18px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 0; padding-bottom: 14px;">Greetings '
		)+ convert (varchar(max),sFirstName) + convert (varchar(max),
				'</h2>
			<p style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; padding-top: 0; padding-bottom: 14px; font-weight: normal; margin-top: 0; margin-right: 0; margin-bottom: 0; margin-left: 0;">Physicians know that they can find quality jobs at the <a href="http://www.nejmcareercenter.org" target="_blank" title="Find Physician Jobs at the NEJM CareerCenter" style="color: #006892; text-decoration: none; font-weight: bold;">NEJM CareerCenter</a>, so make sure you take advantage of all the great features your account has to offer.</p>
			<h4 style="color: black !important; font-size: 13px; line-height: 16px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 0; padding-bottom: 7px; font-style: italic;"><a href="https://recruiters.nejmcareercenter.org/login/" target="_blank" title="Log in to your account" style="color: #006892 !important; text-decoration: none; font-weight: bold;">Log in to your account</a> at any time to:</h4>
			<table id="bullets" border="0" cellspacing="0" cellpadding="5" style="border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;">
				<tr>
					<td width="10" align="right" valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;">&bull; </td>
					<td valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;"><a href="https://recruiters.nejmcareercenter.org/post-a-job/" title="Post a Physician Job" style="color: #006892; text-decoration: none; font-weight: bold;">post</a> a physician job.</td>
				</tr>
				<tr>
					<td width="10" align="right" valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;">&bull; </td>
					<td valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;"><a href="https://recruiters.nejmcareercenter.org/candidate-search/" title="Search Physician Jobs" style="color: #006892; text-decoration: none; font-weight: bold;">search</a> physician profiles (only available to advertisers with live job postings).</td>
				</tr>
				<tr>
					<td width="10" align="right" valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;">&bull; </td>
					<td valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;"><a href="https://recruiters.nejmcareercenter.org/application-listing/" title="View stats" style="color: #006892; text-decoration: none; font-weight: bold;">manage</a> your applications.</td>
				</tr>
				<tr>
					<td width="10" align="right" valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;">&bull; </td>
					<td valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;">access <a href="http://www.nejmcareercenter.org/minisites/rpt/" title="Recruiting Physicians Today (RPT)" style="color: #006892; text-decoration: none; font-weight: bold;">Recruiting Physicians Today (RPT)</a> for current physician recruitment articles.</td>
				</tr>
				<tr>
					<td width="10" align="right" valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;">&bull; </td>
					<td valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;"><a href="http://employer.nejmcareercenter.org/rates/ratecard2013.pdf" title="Access to current rate card" style="color: #006892; text-decoration: none; font-weight: bold;">access</a> current rate card (PDF).</td>
				</tr>
			</table>
			<br />
			<p style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; padding-top: 0; padding-bottom: 14px; font-weight: normal; margin-top: 0; margin-right: 0; margin-bottom: 0; margin-left: 0;"><a href="mailto:ads@nejmcareercenter.org?subject=NEJM CareerCenter" style="color: #006892; text-decoration: none; font-weight: bold;">Customer service</a> is available to answer any questions you may have regarding your account. Please call us at <span class="mobile_link">800-635-6991</span> and a representative will be happy to assist you.</p>
			<p style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; padding-top: 0; padding-bottom: 14px; font-weight: normal; margin-top: 0; margin-right: 0; margin-bottom: 0; margin-left: 0;">The NEJM CareerCenter Team</p>
			</td>
	</tr>
	<tr>
		<td class="footer" style="padding-top: 15px; padding-right: 15px; padding-bottom: 15px; padding-left: 15px;"><p style="color: #666666 !important; font-size: 12px !important; line-height: 17px !important; font-family: Arial, Arial, Helvetica, sans-serif; padding-top: 0; padding-bottom: 14px; font-weight: normal; margin-top: 0; margin-right: 0; margin-bottom: 0; margin-left: 0;">You have received this solicitation because your email address appears in the NEJM CareerCenter classified advertising database. If you do not wish to receive emails from the NEJM CareerCenter, please <a href="#" style="color: #006892; text-decoration: none; font-weight: bold;">click here</a> to unsubscribe to future emails.</p>
			<p style="color: #666666 !important; font-size: 12px !important; line-height: 17px !important; font-family: Arial, Arial, Helvetica, sans-serif; padding-top: 0; padding-bottom: 14px; font-weight: normal; margin-top: 0; margin-right: 0; margin-bottom: 0; margin-left: 0;">The NEJM CareerCenter is a product of NEJM Group, a division of the Massachusetts Medical Society.</p></td>
	</tr>
</table>
<!-- End of wrapper table -->
</body>
</html>')
		,[Body_Format] = 'HTML'
	--	,[Attachments] =  '\\corpprod1\shared\Temp File Share\MadGex\nejmCareerCenter-60px.gif;\\corpprod1\shared\Temp File Share\MadGex\nejmID-preferred-logo28px.gif'
  --select *
  FROM [MadGex_Emails].[dbo].[NewUsers_Stage]
  WHERE WelcomeEmailQueued is null
  
  UPDATE [MadGex_Emails].[dbo].[NewUsers_Stage]
  SET WelcomeEmailQueued = getdate()
  WHERE WelcomeEmailQueued is null
  
  
  Commit transaction
  
  --*****************************************
  -- PROCESS CONFIRMATION EMAILS
  -- select * from [mms_Email]
  --*****************************************
  
  Begin Transaction
/****** Script for SelectTopNRows command from SSMS  ******/
INSERT  [MadGex_Emails].[dbo].[mms_Email]
      ([Profile_Name]
      ,[recipients]
      ,[Copy_Recipients]
      ,[BCC_Recipients]
      ,[Subject]
      ,[Body]
      ,[Body_Format]
      --,[Attachments]
      )

   
 SELECT 
		[Profile_Name] = 'MadGex'
		,[sContactEmailAddress]
		,[Copy_Recipients] = null
		,[BCC_Recipients] = null
		,[Subject] = 'Your job ad is now live on NEJM CareerCenter'
		,[Body] = convert ( varchar(max),'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<!-- Begin Mobile Viewport -->
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<!-- End Mobile Viewport -->
<title>Your Message Subject or Title</title>
<style type="text/css">
/***************************************************
		****************************************************
		MOBILE TARGETING
		****************************************************
		***************************************************/

		@media only screen and (max-device-width: 480px) {
/* Part one of controlling phone number linking for mobile. */
a[href^="tel"], a[href^="sms"] {
	text-decoration: none;
	color: blue; /* or whatever your want */
	pointer-events: none;
	cursor: default;
}
.mobile_link a[href^="tel"], .mobile_link a[href^="sms"] {
	text-decoration: default;
	color: #006892 !important;
	pointer-events: auto;
	cursor: default;
	font-weight: bold;
}
table[id=backgroundTable] {
	margin:10px;
	padding:0;
	width:320px !important;
	line-height: 100% !important;
}
table[id=NEJMPreferredIDTable] {
	margin-top: 80px;
	width:100% !important;
}
td[class=NEJMPreferredID] {
	background-image: url(''http://employer.nejmcareercenter.org/images/nejmID-preferred@2x.png'') !important;
	background-repeat:no-repeat;
!important;
	background-size: 182px 28px;
}
td[class=NEJMPreferredID] img {
	display: none;
}
td[class=NEJMCCID] {
	background-image: url(''http://employer.nejmcareercenter.org/images/nejmCareerCenter@2x.png'') !important;
	background-repeat:no-repeat;
!important;
	background-size: 234px 60px;
}
td[class=NEJMCCID] img {
	display:none;
}
}

		/* More Specific Targeting */

		@media only screen and (min-device-width: 768px) and (max-device-width: 1024px) {
/* You guessed it, ipad (tablets, smaller screens, etc) */
			/* repeating for the ipad */
	a[href^="tel"], a[href^="sms"] {
	text-decoration: none;
	color: #006892!important; /* or whatever your want */
	pointer-events: none;
	cursor: default;
}
.mobile_link a[href^="tel"], .mobile_link a[href^="sms"] {
	text-decoration: none;
	color: #006892 !important;
	pointer-events: auto;
	cursor: default;
}
}
</style>

<!-- Targeting Windows Mobile -->
<!--[if IEMobile 7]>
	<style type="text/css">
	
	</style>
	<![endif]-->

<!-- ***********************************************
	****************************************************
	END MOBILE TARGETING
	****************************************************
	************************************************ -->

<!--[if gte mso 9]>
		<style>
		/* Target Outlook 2007 and 2010 */
		</style>
	<![endif]-->
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0" style="-webkit-font-smoothing: antialiased;width:100% !important;background:#ffffff;-webkit-text-size-adjust:none;">
<style type="text/css">
a { color: #006892 !important; text-decoration: none !important;}
a:hover {text-decoration:underline;}
</style>
<table cellpadding="0" cellspacing="0" border="0" id="backgroundTable" style="width: 520px; line-height: 100% !important; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; margin-top: 10px; margin-right: 10px; margin-bottom: 10px; margin-left: 10px; padding-top: 0; padding-right: 0; padding-bottom: 0; padding-left: 0;">
	<tr>
		<td valign="bottom" class="NEJMCCID" style="padding-top: 0; padding-right: 15px; padding-bottom: 15px; padding-left: 15px;"><a href="http://www.nejmcareercenter.org/" target =" _blank="" title="Find Physician Jobs at the NEJM CareerCenter" style="color: #006892; text-decoration: none; font-weight: bold;"><img src="http://employer.nejmcareercenter.org/images/nejmCareerCenter-60px.gif" alt="Visit the NEJM CareerCenter" title="Visit the NEJM CareerCenter" width="234" height="60" border="0" style="outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; border-top-style: none; border-right-style: none; border-bottom-style: none; border-left-style: none;" /></a>
			<table id="NEJMPreferredIDTable" border="0" align="right" cellpadding="0" cellspacing="0" style="border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 186px;">
				<tr>
					<td class="NEJMPreferredID" style="padding-top: 30px;"><a href="http://www.nejm.org/" target="_blank" title="Visit NEJM.org" style="color: #006892; text-decoration: none; font-weight: bold;"><img src="http://employer.nejmcareercenter.org/images/nejmID-preferred-28px.gif" alt="Visit NEJM.org" title="Visit NEJM.org" width="182" height="28" border="0" style="outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; border-top-style: none; border-right-style: none; border-bottom-style: none; border-left-style: none;" /></a></td>
				</tr>
			</table></td>
	</tr>
	<tr>
		<td class="content" valign="top" style="padding-top: 15px; padding-right: 15px; padding-bottom: 15px; padding-left: 15px; border-top-style: solid; border-right-color: #CCCCCC; border-bottom-color: #CCCCCC; border-left-color: #CCCCCC; border-top-color: #CCCCCC; border-right-style: solid; border-bottom-style: solid; border-left-style: solid; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px;"><h1 style="color: black !important; font-size: 18px; line-height: 23px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 0; padding-bottom: 24px; text-align: center;" align="center">Your job posting has been approved.</h1>
			<p style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; padding-top: 0; padding-bottom: 14px; font-weight: normal; margin-top: 0; margin-right: 0; margin-bottom: 0; margin-left: 0;">Your job is now live on <a href="http://www.nejmcareercenter.org" target="_blank" title="Find Physician Jobs at the NEJM CareerCenter" style="color: #006892; text-decoration: none; font-weight: bold;">NEJM CareerCenter</a>.</p>
			<p style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; padding-top: 0; padding-bottom: 14px; font-weight: normal; margin-top: 0; margin-right: 0; margin-bottom: 0; margin-left: 0;">The information below summarizes your job details. Please keep this information for future reference.</p>
			<table id="details" border="0" cellspacing="0" cellpadding="5" style="border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%; margin-top: 0; margin-right: 0; margin-bottom: 15px; margin-left: 0;">
				<tr style="border-bottom-width: 1px; border-bottom-color: #cccccc; border-bottom-style: solid;">
					<th colspan="2" style="text-align: left; font-family: Arial, Arial, Helvetica, sans-serif; font-size: 14px; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; background-color: #fff8e8; border-top-style: solid; border-right-color: #cccccc; border-bottom-color: #cccccc; border-left-color: #cccccc; border-top-color: #cccccc; border-right-style: solid; border-bottom-style: solid; border-left-style: solid; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px;" align="left" bgcolor="#fff8e8"> Job Details </th>
				</tr>
				<tr style="border-bottom-width: 1px; border-bottom-color: #cccccc; border-bottom-style: solid;">
					<td width="105" align="right" valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal; border-top-color: #cccccc; border-right-color: #cccccc; border-bottom-color: #cccccc; border-left-color: #cccccc; border-top-style: solid; border-right-style: solid; border-bottom-style: solid; border-left-style: solid; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px; background-color: #f8f8f8;" bgcolor="#f8f8f8"><strong>Title: </strong></td>
					<td valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal; border-top-color: #cccccc; border-right-color: #cccccc; border-bottom-color: #cccccc; border-left-color: #cccccc; border-top-style: solid; border-right-style: solid; border-bottom-style: solid; border-left-style: solid; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px; background-color: #f8f8f8;" bgcolor="#f8f8f8"><a href="http://www.nejmcareercenter.org/job/')
		+ convert(varchar(max),JobID) +'/" target="_blank" title="" style="color: #006892; text-decoration: none; font-weight: bold;">  '+ convert (varchar(max),sTitle)+
		convert (varchar(max),'</a>
				</td>
				</tr>
				<tr style="border-bottom-width: 1px; border-bottom-color: #cccccc; border-bottom-style: solid;">
					<td width="105" align="right" valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal; border-top-color: #cccccc; border-right-color: #cccccc; border-bottom-color: #cccccc; border-left-color: #cccccc; border-top-style: solid; border-right-style: solid; border-bottom-style: solid; border-left-style: solid; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px; background-color: #f8f8f8;" bgcolor="#f8f8f8"><strong>Location:</strong></td>
					<td valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal; border-top-color: #cccccc; border-right-color: #cccccc; border-bottom-color: #cccccc; border-left-color: #cccccc; border-top-style: solid; border-right-style: solid; border-bottom-style: solid; border-left-style: solid; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px; background-color: #f8f8f8;" bgcolor="#f8f8f8">  '
		+ Location +
			'</td>
				</tr>
				<tr style="border-bottom-width: 1px; border-bottom-color: #cccccc; border-bottom-style: solid;">
					<td width="105" align="right" valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal; border-top-color: #cccccc; border-right-color: #cccccc; border-bottom-color: #cccccc; border-left-color: #cccccc; border-top-style: solid; border-right-style: solid; border-bottom-style: solid; border-left-style: solid; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px; background-color: #f8f8f8;" bgcolor="#f8f8f8"><strong>Specialty:</strong></td>
					<td valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal; border-top-color: #cccccc; border-right-color: #cccccc; border-bottom-color: #cccccc; border-left-color: #cccccc; border-top-style: solid; border-right-style: solid; border-bottom-style: solid; border-left-style: solid; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px; background-color: #f8f8f8;" bgcolor="#f8f8f8">  '
		+ Specialty +
			'</td>
				</tr>
				<tr style="border-bottom-width: 1px; border-bottom-color: #cccccc; border-bottom-style: solid;">
					<td width="105" align="right" valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal; border-top-color: #cccccc; border-right-color: #cccccc; border-bottom-color: #cccccc; border-left-color: #cccccc; border-top-style: solid; border-right-style: solid; border-bottom-style: solid; border-left-style: solid; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px; background-color: #f8f8f8;" bgcolor="#f8f8f8"><strong>Expiration Date:</strong></td>
					<td valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal; border-top-color: #cccccc; border-right-color: #cccccc; border-bottom-color: #cccccc; border-left-color: #cccccc; border-top-style: solid; border-right-style: solid; border-bottom-style: solid; border-left-style: solid; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px; background-color: #f8f8f8;" bgcolor="#f8f8f8">  '
		+ convert(varchar(max),ExpirationDate,101)+ 
		'</td>
				</tr>
			</table>
			<h4 style="color: black !important; font-size: 13px; line-height: 16px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 0; padding-bottom: 7px; font-style: italic;"><a href="https://recruiters.nejmcareercenter.org/login/" target="_blank" title="Log in to your account" style="color: #006892 !important; text-decoration: none; font-weight: bold;">Log in to your account</a> at any time to:</h4>
			<table id="bullets" border="0" cellspacing="0" cellpadding="5" style="border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;">
				<tr>
					<td width="10" align="right" valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;">&bull; </td>
					<td valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;"><a href="https://recruiters.nejmcareercenter.org/candidate-search/" title="Search Physician Jobs" style="color: #006892; text-decoration: none; font-weight: bold;">search</a> physician profiles.</td>
				</tr>
				<tr>
					<td width="10" align="right" valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;">&bull; </td>
					<td valign="top" style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; margin-top: 0; margin-bottom: 0; padding-top: 5px; padding-bottom: 5px; font-weight: normal;"><a href="https://recruiters.nejmcareercenter.org/application-listing/" title="View stats" style="color: #006892; text-decoration: none; font-weight: bold;">manage</a> your applications.</td>
				</tr>
			</table>
			<br />
			<p style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; padding-top: 0; padding-bottom: 14px; font-weight: normal; margin-top: 0; margin-right: 0; margin-bottom: 0; margin-left: 0;"><a href="mailto:ads@nejmcareercenter.org?subject=NEJM CareerCenter" style="color: #006892; text-decoration: none; font-weight: bold;">Customer service</a> is available to answer any questions you may have regarding your account. Please call us at <span class="mobile_link"><strong>800-635-6991</strong></span> and a representative will be happy to assist you.</p>
			<p style="color: #000000; font-size: 12px; line-height: 17px; font-family: Arial, Arial, Helvetica, sans-serif; padding-top: 0; padding-bottom: 14px; font-weight: normal; margin-top: 0; margin-right: 0; margin-bottom: 0; margin-left: 0;">The NEJM CareerCenter Team</p>
		
		</td>

	</tr>
	<tr>
	
		<td class="footer" style="padding-top: 15px; padding-right: 15px; padding-bottom: 15px; padding-left: 15px;"><p style="color: #666666 !important; font-size: 12px !important; line-height: 17px !important; font-family: Arial, Arial, Helvetica, sans-serif; padding-top: 0; padding-bottom: 14px; font-weight: normal; margin-top: 0; margin-right: 0; margin-bottom: 0; margin-left: 0;">You have received this solicitation because your email address appears in the NEJM CareerCenter classified advertising database. If you do not wish to receive emails from the NEJM CareerCenter, please <a href="#" style="color: #006892; text-decoration: none; font-weight: bold;">click here</a> to unsubscribe to future emails.</p>
			<p style="color: #666666 !important; font-size: 12px !important; line-height: 17px !important; font-family: Arial, Arial, Helvetica, sans-serif; padding-top: 0; padding-bottom: 14px; font-weight: normal; margin-top: 0; margin-right: 0; margin-bottom: 0; margin-left: 0;">The NEJM CareerCenter is a product of NEJM Group, a division of the Massachusetts Medical Society.</p></td>
	</tr>
</table>
<!-- End of wrapper table -->
</body>
</html>')
		,[Body_Format] = 'HTML'
	--	,[Attachments] =  '\\corpprod1\shared\Temp File Share\MadGex\nejmCareerCenter-60px.gif;\\corpprod1\shared\Temp File Share\MadGex\nejmID-preferred-logo28px.gif'
  --select * 
  FROM [MadGex_Emails].[dbo].[JobPosters_Stage]
  WHERE ConfirmEmailQueued is null
  
  UPDATE [MadGex_Emails].[dbo].[JobPosters_Stage]
  SET ConfirmEmailQueued = getdate()
  WHERE ConfirmEmailQueued is null
  
  
  Commit transaction
  
  end try
begin catch
	--if a transaction was started, rollback
	if @@trancount > 0
	begin
		rollback transaction
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

end catch



GO

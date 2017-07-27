#Requires –Version 3
#Requires –Modules WindowsServerBackup

<#
    PowerShell Windows Server Backup Report
    Twitter: @GavinEke
    
    Requires Windows Server Backup Command Line Tools
    This version is for Windows Server 2012+
    Example usage: .\Get-WBReport.ps1
#>

# Public Varibles
$MailMessageTo = "backup.user@nrhawv.org" # List of users to email your report to (separate by comma)
$MailMessageFrom = "backup.user@nrhawv.org" # Enter the email you would like the report sent from
$MailMessageSMTPServer = "mail.nrhawv.org" # Enter your own SMTP server DNS name / IP address here
$MailMessagePriority = "Normal" # Low/Normal/High


# DO NOT CHANGE ANYTHING PAST THIS LINE!

# Private Variables
$WBJob = Get-WBJob -Previous 1
$WBSummary = Get-WBSummary
$WBJobStartTime = $WBJob.StartTime
$WBJobEndTime = $WBJob.EndTime
$WBJobSuccessLog = Get-Content -Path $WBJob.SuccessLogPath
$WBJobFailureLog = Get-Content -Path $WBJob.FailureLogPath

# Change Result of 0 to Success in green text and any other result as Failure in red text
If ($WBSummary.LastBackupResultHR -eq 0) {
    $WBJobResult = "Successful"
    $WBJobLog = $WBJobSuccessLog
} Else {
    $WBJobResult = "Failed"
    $WBJobLog = $WBJobFailureLog
}


$HTMLMessageSubject = $env:computername+ " " + $WBJobResult +": Backup Report - "+(Get-Date) # Email Subject
# Assemble the HTML Report
$HTMLMessage = @"
<!DOCTYPE html>
<html>
<head>
<title>$HTMLMessageSubject</title>
<style>
h1.Successful {color:green;}
h1.Failed {color:red;}
</style>
</head>
<body>
<h1 class="$WBJobResult">Backup $WBJobResult</h1>
Start: $WBJobStartTime<br>
Finished: $WBJobEndTime<br>
<br>
<p>Log:</p>
<br>
$WBJobLog
</body>
</html>
"@

# Email the report
$MailMessageOptions = @{
    From            = "$MailMessageFrom"
    To              = "$MailMessageTo"
    Subject         = "$HTMLMessageSubject"
    BodyAsHTML      = $True
    Body            = "$HTMLMessage"
    Priority        = "$MailMessagePriority"
    SmtpServer      = "$MailMessageSMTPServer"
}
Send-MailMessage @MailMessageOptions
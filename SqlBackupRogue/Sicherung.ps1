# author : Fabricio Gil
# Comment          Date

# Inital version  : 24-nov-2021
# 1.1             : 2-Dec-2021      Add parameter backup type 
# 1.2             : 6-Dec-2021      Add Email Backup Status       
# author : Fabricio Gil

param (
	[Parameter(Mandatory=$True)]
	[ValidateNotNull()]
	[string]$Type	
)

if ( $Type.ToUpper() -eq "FULL"   -or  $Type.ToUpper() -eq "DIFF"  -or  $Type.ToUpper() -eq "LOG" ) 
{


        # getting credentials to access gcp dbs
        $ExecutionTime =  (Get-Date)
        $currentoutputfile = "C:\dataeng\BackupGcpVerDbs\log\backuplog at "+$ExecutionTime.ToString("yyyy_MM_dd_hhmmss")+".log"
        $benutzer = "tc3-gwl\srv_2196_vsql"
        $pass = Get-Content "C:\dataeng\BackupGcpVerDbs\Passwort.txt" | ConvertTo-SecureString

        $referenzen = New-Object System.Management.Automation.PSCredential -ArgumentList ($benutzer,$pass)

        $bpath = "D:\sql_backups\" + $Type  

        # validate if directory exists if not created it!

        $monate = $ExecutionTime.Month

        $monatename = $monate | %{(Get-Culture).DateTimeFormat.GetMonthName($_)}

        $jarhe = $ExecutionTime.Year

        $bpath = $bpath + "\" + [string]$jarhe + "\" + $monatename
        
      
         
        Import-Csv  -Path C:\dataeng\BackupGcpVerDbs\folge.csv |ForEach-Object {
                            Write-Host " Processing Backup for $($_.DB) database at   $($_.SRV)"
                              $log = Backup-DbaDatabase -SqlCredential $referenzen -SqlInstance  $($_.SRV) -Database $($_.DB) -Type $Type -FilePath backuptype-dbname-timestamp.bak -ReplaceInName  -Path $bpath  -BuildPath           
                              $log | Out-File $currentoutputfile -Append
                            }
       

      }       
else
{
	Write-host -foregroundcolor "Red" "$(Get-Date) : TYPE must be either FULL,DIFF or LOG"
	Add-Content $currentoutputfile "$(Get-Date) : TYPE must be either FULL,DIFF or LOG" 
	exit 102
}


$recipients = @("fabricio.gil@telusinternational.com";"allan.agustin@telusinternational.com";"edith.herrera@telusinternational.com")

$vsubject = 'CL Verint Backup execution at '+ $ExecutionTime.ToString("yyyy-MM-dd:hh-mm-ss")

# send report only on odd hours to

if ( $ExecutionTime.Hour % 2 -eq 1){

    send-mailmessage -SmtpServer "100.77.84.104" -From "reporting.donotreply@telus.com" -To $recipients -Subject $vsubject -Body "Good Morning Team. Please find in the attachment the report"   -Attachments $currentoutputfile
}



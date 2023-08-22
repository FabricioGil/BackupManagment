param (
	[Parameter(Mandatory=$False)]
	[ValidateNotNull()]
	[string]$DBName,	
    #[Parameter(Mandatory=$True)]
	#[ValidateNotNull()]
	#[string]$DBUSER,
	#[Parameter(Mandatory=$true)]
	#[ValidateNotNull()]
	#[string]$DBPASS,cls
	[Parameter(Mandatory=$true)]
	[ValidateNotNull()]
	[boolean]$Continue	
)

function Parse-Ini ($config)
{
	if([System.IO.File]::Exists($config))
	{
		switch -regex -file $config
		{
			"^\[(.+)\]$"
			{
			  $section = $matches[1].Trim()
			  $ini[$section] = @{}
			  continue
			}
			"^\s*([^#].+?)\s*=\s*(\d+)\s*$"
			{
			  $name,$value = $matches[1..2]
			  $ini[$section][$name] = [int]$value
			  continue
			}
			"^\s*([^#].+?)\s*=\s*(\d+\.\d+)\s*$"
			{
			  $name,$value = $matches[1..2]
			  $ini[$section][$name] = [decimal]$value
			  continue
			}
			"^\s*([^#].+?)\s*=\s*(.*)"
			{
			  $name,$value = $matches[1..2]
			  $ini[$section][$name] = $value.Trim()
			}
		}
	}
	else
	{
		Write-host -foregroundcolor "Red" "$(Get-Date) : Config file contains error, please correct and run again."
		exit 101
	}
}


function run_sql ($INSTANCE, $DBUSER, $DBPASS, $f, $log, $err, $c, $eC)
{
	$exeplans = Get-Content($f)
	$logfile = "$log"
	$errfile = "$err"
	$server = $env:computername
	$user = $DBUSER
	$pass = $DBPASS
	$counter = $c
	$errCnt = $eC
	
	foreach ($exeplan in $exeplans)
	{
		$items = (Get-ChildItem -path $exeplan -Recurse)

		$sortitems = New-Object -typeName System.Collections.Arraylist
		foreach ($item in $items)
		{
			if ($item.Attributes -ne "Directory")
			{
				$sortitems.add($item.fullname) | out-null
			}
		}
		$sortitems = $sortitems | Sort-Object

		foreach ($sortitem in $sortitems)
		{
		$errCnt
		$counter
		$cont
			if (( $cont -eq $True ) -and ($counter -lt $errCnt))
			{
				write-host "Skipping `"$sortitem`", as it has been processed by previous run."
				Add-Content $logfile "$(Get-Date) : Skipping `"$sortitem`", as it has been processed by previous run." 
			}
			else
			{			
				
				if ( $sortitem.EndsWith("exe"))
				{
					write-host "Invoke-Command -scriptblock { `"$sortitem`" }"
					Add-Content $logfile "$(Get-Date) : Invoke-Command -scriptblock { `"$sortitem`" }" 
					& $sortitem
					Write-Host "Press any key to continue ..."
					$stop = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
				}
				elseif ( $sortitem.EndsWith("dnr"))
				{
					write-host "Skipping this : `"/c $sortitem`""
					Add-Content $logfile "$(Get-Date) : Skipping this : `"/c $sortitem`"" 
				}
				elseif ( $sortitem.EndsWith("bat"))
				{
					write-host "start-process `"cmd.exe`" `"/c $sortitem`""
					Add-Content $logfile "$(Get-Date) : start-process `"cmd.exe`" `"/c $sortitem`"" 
					start-process "cmd.exe" "/c $sortitem"
				}
				else
				{
					write-host "Invoke-Sqlcmd -ServerInstance $INSTANCE -Database $Dbname -Username $user -Password -InputFile `"$sortitem`""
					Add-Content $logfile "$(Get-Date) : Invoke-Sqlcmd -ServerInstance $server\$INSTANCE -Database $Dbname -Username $user -Password -InputFile `"$sortitem`"" 
					#$sqlout = Invoke-Sqlcmd -ServerInstance $server\$INSTANCE -Database $dbname -Username $user -Password $pass -InputFile $sortitem -QueryTimeout 10800	
                   # if ($server -eq $INSTANCE)
                    #{
                      Invoke-Sqlcmd -ServerInstance $INSTANCE -Database $dbname -Username $user -Password $pass -InputFile $sortitem -QueryTimeout 1800 2>&1 | out-file $logfile -append
                    #}
					#else
                    #{
                    #  Invoke-Sqlcmd -ServerInstance $server\$INSTANCE -Database $dbname -Username $user -Password $pass -InputFile $sortitem -QueryTimeout 1800 2>&1 | out-file $logfile -append
                    #}
					

					if ($? -ne $true)
					{
						$Counter | out-file $errfile
						exit 201
					}
				}				
			}
			$counter += 1
		}
	}
}



$config = "B:\GIOS\DBA\BackupManagment\Conf\BkInstall.ini"
$ini = @{}
$Date = Get-Date -format "yyyyMMdd-HHmmss" 
$logfile = ""
$errFile = ""
$Cont = $Continue
$Counter = 0
$errCnt = $null 
$Type = "CREATION" 
$DBName = "DbAdmin"

#Main script starts here
Parse-Ini $config
$logdir = $ini.LOG.LOG_DIR
$Servername = $ini.DB.SERVER
$SQLCredentials = Get-Credential
$DBUSER= $SQLCredentials.GetNetWorkCredential().UserName
$DBPASS= $SQLCredentials.GetNetWorkCredential().password

if ( $Type.ToUpper() -Match "CREATION" )
{
	$logfile = "$logdir\UWF_Creation.$DATE.log"
	$errfile = "$logdir\UWF_Creation.err"
	
	if ($cont -eq $false)
	{
		clear-content $errfile
	}
	
	if ([System.IO.File]::Exists($errfile))
	{
		$errCnt = Get-Content $errfile
	}
	
	$creationinput = $ini.CREATION.INPUTFILE
	
	if ([System.IO.File]::Exists($creationinput))
	{
		run_sql $Servername $DBUSER $DBPASS $creationinput $logfile $errfile $Counter $errCnt
	}
	else
	{
		Write-host -foregroundcolor "Red" "$(Get-Date) : Creation input file does not exist" 
		Add-Content $logfile "$(Get-Date) : Creation input file does not exist" 
		exit 103
	}
}

else
{
	Write-host -foregroundcolor "Red" "$(Get-Date) : TYPE must be either CREATION or MIGRATION"
	Add-Content $logfile "$(Get-Date) : TYPE must be either CREATION or MIGRATION" 
	exit 102
}

    
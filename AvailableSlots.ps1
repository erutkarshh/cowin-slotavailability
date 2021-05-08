$date = Read-Host "Please enter desired slot date (dd-mm-yyyy)"#"06-05-2021"
$minAgeLimit = Read-Host "Please enter age group (18 or 45)" # 18 or 45
$waitSeconds = 10
$flag = 0

$id= Read-Host "Please enter district id (default is Pune)"
if($id -eq '')
{
	$id = 393 # default value
}

try
{
	do
	{
	$currentTime = Get-Date -Format "dd/MMM/yyyy HH:mm:ss"
	$uri = "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=$id&date=$date"
	$webData = Invoke-RestMethod -Uri $uri
	$dataCount = 0
	if($webData.sessions -ne $null -and $webData.sessions.Count -gt 0)
	{

		foreach($session in $webData.sessions)
		{
			if($session.min_age_limit -eq $null -OR $session.min_age_limit -le $minAgeLimit)
			{
				write-host "Block: "$session.block_name",			Pin Code: "$session.pincode",	" -nonewline        
				write-host "Available: "$session.available_capacity -ForegroundColor White -BackgroundColor DarkGreen

				$dataCount = $dataCount + 1        
			}          
		}    
	}

	if($dataCount -eq 0)
	{
		Write-Host "No slot available." -ForegroundColor White -BackgroundColor Red
	}
	else
	{
		[console]::beep(3000,500)
	}

	Write-Host
	Write-Host "LastRefresh: $currentTime, Age Group: $minAgeLimit Years, Next Refresh In: $waitSeconds Seconds" -ForegroundColor Black -BackgroundColor Yellow
	Write-Host "---------------------------------------------------------"
	Start-Sleep -s $waitSeconds
	}while($flag -eq 0)

}
catch{
	write-error "An Error Occurred."
}

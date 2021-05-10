$date = Read-Host "Please enter desired slot date (dd-mm-yyyy)"#"12-05-2021"
$minAgeLimit = Read-Host "Please enter age group (18 or 45)" # 18
$waitSeconds = 10
$flag = 0

$stateId = 0;
$districtId = 0;

try
{
	# find state
	do
	{
		$stateName = Read-Host "Please enter state name. E.g. madhya pradesh"
		$uriStates = "https://cdn-api.co-vin.in/api/v2/admin/location/states"
		$webDataStates = Invoke-RestMethod -Uri $uriStates
		$stateData = $webDataStates.states | where-object { $_.state_name -like "*$stateName*" } | Select $_
		$dataCount = $stateData | measure
		if($dataCount.count -eq 1)
		{
			Write-Host "Is this correct state name? " -nonewline
			Write-Host $stateData.state_name -ForegroundColor White -BackgroundColor DarkGreen
			$correctState = Read-Host "Y/N?"
			if($correctState -eq 'y' -or $correctState -eq 'Y')
			{
				$stateId = $stateData.state_id
				$flag = 1
			}
			else
			{
				write-host 'Try Again.' -ForegroundColor White -BackgroundColor Red
			}
		}
		else
		{
			write-host 'Not able to find exact record. Try Again with another word.' -ForegroundColor White -BackgroundColor Red
		}
	}while($flag -eq 0)
	
	# find district
	do
	{
		$districtName = Read-Host "Please enter district name. E.g. gwalior"
		$uriDistricts = "https://cdn-api.co-vin.in/api/v2/admin/location/districts/$stateId"
		$webDataDistricts = Invoke-RestMethod -Uri $uriDistricts
		$districtData = $webDataDistricts.districts | where-object { $_.district_name -like "*$districtName*" } | Select $_
		$dataCount = $districtData | measure
		if($dataCount.Count -eq 1)
		{
			Write-Host "Is this correct district name? " -nonewline
			Write-Host $districtData.district_name -ForegroundColor White -BackgroundColor DarkGreen
			$correctDistrict = Read-Host "Y/N?"
			if($correctDistrict -eq 'y' -or $correctDistrict -eq 'Y')
			{
				$districtId = $districtData.district_id
				$flag = 2
			}
			else
			{
				write-host 'Try Again.' -ForegroundColor White -BackgroundColor Red
			}
		}
		else
		{
			write-host 'Not able to find exact record. Try Again with another word.' -ForegroundColor White -BackgroundColor Red
		}
	}while($flag -eq 1)
	
	# find slots
	do
	{
	$currentTime = Get-Date -Format "dd/MMM/yyyy HH:mm:ss"
	$uri = "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=$districtId&date=$date"
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
	}while($flag -eq 2)

}
catch{
	write-error "An Error Occurred."
}

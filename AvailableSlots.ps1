$date = Read-Host "Please enter desired slot date (dd-mm-yyyy)"#"06-05-2021"
$minAgeLimit = Read-Host "Please enter age group (18 or 45)" # 18 or 45
$waitSeconds = 10
$flag = 0

$stateId = 0;
$districtId = 0;

try
{
	# find state
	do
	{
		$stateName = Read-Host "Please enter state name. E.g. maharashtra"
		$uriStates = "https://cdn-api.co-vin.in/api/v2/admin/location/states"
		$webDataStates = Invoke-RestMethod -Uri $uriStates
		$stateData = $webDataStates.states | where-object { $_.state_name -like "*$stateName*" } | Select $_
		$dataCount = $stateData | measure
		if($dataCount.count -eq 1)
		{
			Write-Host "Is this correct state name? " -nonewline
			Write-Host $stateData.state_name -ForegroundColor White -BackgroundColor DarkGreen
			$correctState = Read-Host "y/n?"
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
		$districtName = Read-Host "Please enter district name. E.g. pune"
		$uriDistricts = "https://cdn-api.co-vin.in/api/v2/admin/location/districts/$stateId"
		$webDataDistricts = Invoke-RestMethod -Uri $uriDistricts
		$districtData = $webDataDistricts.districts | where-object { $_.district_name -like "*$districtName*" } | Select $_
		$dataCount = $districtData | measure
		if($dataCount.Count -eq 1)
		{
			Write-Host "Is this correct district name? " -nonewline
			Write-Host $districtData.district_name -ForegroundColor White -BackgroundColor DarkGreen
			$correctDistrict = Read-Host "y/n?"
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

	# post code
    $pincodeChoice = Read-Host "Please enter choice of pincode(s)(411026,411027,411028 or default is all)"
    if($pincodeChoice -eq '')
    {
	    $pincodeChoice = "ALL"
    }
	
	# dose type
	$doseType = Read-Host "Please enter choice of dose (for 1st dose press 1, for 2nd dose press 2, default is 1st dose)"
    if($doseType -ne '1' -and $doseType -ne '2')
    {
	    $doseType = "1"
    }
	Write-Host "DoseSelected: " -nonewline
	Write-Host $doseType -ForegroundColor White -BackgroundColor DarkGreen
	
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
                if($pincodeChoice -eq "ALL")
                {				    
					if($doseType -eq '1' -and $session.available_capacity_dose1 -ne '0')
					{
						write-host "Block:"$session.block_name",	Pin Code:"$session.pincode", Vaccine:"$session.Vaccine",	Fee(Rupees):"$session.Fee",	" -nonewline
						write-host "Available (1st Dose): "$session.available_capacity_dose1 -ForegroundColor White -BackgroundColor DarkGreen						
					
						$dataCount = $dataCount + 1        
						write-host "======================================================="
					}
					elseif($doseType -eq '2' -and $session.available_capacity_dose2 -ne '0')
					{
						write-host "Block:"$session.block_name",		Pin Code:"$session.pincode", Vaccine:"$session.Vaccine",	Fee(Rupees):"$session.Fee",	" -nonewline
						write-host "Available (2nd Dose): "$session.available_capacity_dose2 -ForegroundColor White -BackgroundColor DarkGreen
						
						$dataCount = $dataCount + 1        
						write-host "======================================================="
					}
                }
                else
                {
                    if($pincodeChoice.contains($session.pincode))
                    {       
				        if($doseType -eq '1' -and $session.available_capacity_dose1 -ne '0')
						{
							write-host "Block:"$session.block_name",		Pin Code:"$session.pincode", Vaccine:"$session.Vaccine",	Fee(Rupees):"$session.Fee",	" -nonewline
							write-host "Available (1st Dose): "$session.available_capacity_dose1 -ForegroundColor White -BackgroundColor DarkGreen
							write-host "Address: "$session.address"" -ForegroundColor White
							
							$dataCount = $dataCount + 1        
							write-host "======================================================="
						}
						elseif($doseType -eq '2' -and $session.available_capacity_dose2 -ne '0')
						{
							write-host "Block:"$session.block_name",		Pin Code:"$session.pincode", Vaccine:"$session.Vaccine",	Fee(Rupees):"$session.Fee",	" -nonewline
							write-host "Available (2nd Dose): "$session.available_capacity_dose2 -ForegroundColor White -BackgroundColor DarkGreen
							write-host "Address: "$session.address"" -ForegroundColor White
							
							$dataCount = $dataCount + 1        
							write-host "======================================================="
						} 
                    }
                }
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
	Write-Host "LastRefresh: $currentTime, Age Group: $minAgeLimit Years, For date: $date, Next Refresh In: $waitSeconds Seconds" -ForegroundColor Black -BackgroundColor Gray
	Write-Host "---------------------------------------------------------"
	Start-Sleep -s $waitSeconds
	}while($flag -eq 2)

}
catch [Exception]{
	Write-Host "An Error Occurred while calling API. $_" -ForegroundColor Red
	[console]::beep(1000,300)
}
finally{	
	Write-Host "Script Stopped. Press any key to exit..."
	Read-Host
}

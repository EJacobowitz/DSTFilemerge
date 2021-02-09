#This script will merge the 2 files provided by sabre to get a single list of all stations and DST settings

#convert date time function
function convert-date1 {
    param (
        [string] $date1,
        [string] $time1
    )

    $day = $date1.Substring(0, 2)
    $month = $date1.Substring(2, 2)
    $year = "20" + $date1.Substring(4, 2)

    $hour = $time1.Substring(0, 2)
    $minutes = $time1.Substring(2, 2)

    $Adate = Get-Date -day $day -month $month -year $year -Hour $hour -Minute $minutes -Second 00
    Return $Adate.tostring("MM/dd/yyyy hh:mm")
    
}

#Get DST Timezone 
if (Test-Path .\TempDSTZones.csv) { Remove-Item .\TempDSTZones.csv }
if (Test-Path .\DSTZones.csv) { Remove-Item .\DSTZones.csv }
$columBreaks = 102, 360, 366, 371, 378, 383, 390
$columBreaks2 = 3, 10, 13

#this will set delimeters for Time zones
(Get-Content IATADSTZones.txt | ForEach-Object {
        $_.insert($columBreaks[0], ",").insert($columBreaks[1], ",").insert($columBreaks[2], ",").insert($columBreaks[3], ",").insert($columBreaks[4], ",").insert($columBreaks[5], ",").insert($columBreaks[6], ",")
    }) | Set-Content TempDSTZones.csv

#this will set delimeters for airports    
(get-content AirportTimesZones.txt | ForEach-Object {
        $_.insert($columBreaks2[0], ",").insert($columBreaks2[1], ",").insert($columBreaks2[2], ",")
    }) | Set-Content TempAirports.csv

#this will create a lookup hashtable
$timezoneTable = @()
foreach ($zones in Get-Content TempDSTZones.csv) {
    $line1 = $zones.Split(",")
    # write-host " $($line1[0].Trim()), $($line1[1].Trim()), $($line1[2].Trim()), $($line1[3].Trim()), $($line1[4].Trim()), $($line1[5].Trim()), $($line1[6].Trim()), $($line1[7].Trim())"
    if ($line1[4].Trim().Length -gt 0) { $dststart = convert-date1 -date1 $line1[4].Trim() -time1 $line1[3].Trim() } else { $dststart = '' }
    if ($line1[6].Trim().Length -gt 0 ) { $dstend = convert-date1 -date1 $line1[6].Trim() -time1 $line1[5].Trim() } else { $dstend = '' }
    $timezoneTable += (@{
            Countrycode = $line1[0].Trim()
            Timezone    = $line1[1].Trim()
            DSTstart    = $dststart
            DSTEnd      = $dstend
            DSTVariant  = $line1[2].Trim()
            Standard    = $line1[7].Trim()
        })

}

#lookup Airport table and hash table to merge data and write it to CSV file.
foreach ($Airport in Get-Content TempAirports.csv) {
    $line = $Airport.split(",")
    foreach ($record in $timezoneTable) {
        if ($record.Countrycode -eq $line[2] -and $record.Timezone -eq $line[3].trim()) {
            $output = "$($line[0]),$($record.countrycode),$($record.Timezone),$($record.DSTstart),$($record.DSTEnd),$($record.DSTVariant),$($record.Standard)"
            if ($null -ne (test-path -path ./AirportDST.csv) ) { $output | Out-File -Path ./AirportDST.csv -Append }else { $output | out-file -Path ./AirportDST.csv }
            #if ($null -ne (test-path -path ./AirportDST.csv) ) { $output | Export-Csv -Path ./AirportDST.csv -Append -NoClobber -NoTypeInformation }else { $output | Export-Csv -Path ./AirportDST.csv -NoClobber -NoTypeInformation }
            
        }    
    } 
}

#Cleanup
if (Test-Path .\TempDSTZones.csv) { Remove-Item .\TempDSTZones.csv }
if (Test-Path .\TempAirports.csv) { Remove-Item .\TempAirports.csv }
if (Test-Path .\DSTZones.csv) { Remove-Item .\DSTZones.csv }
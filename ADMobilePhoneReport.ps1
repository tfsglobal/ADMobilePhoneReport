[CmdletBinding()]
param (
    [string]$DomainControllerName,
    [array]$emailTo,
    [System.Management.Automation.PSCredential]$credential
)

# Functions------------------------------------------------------------------------------------
function Send-CSVReports{
    param(
        $emailTo,
        [System.Management.Automation.PSCredential]$credential
    )

    # Get attachments
    $Attachments = get-childitem $PSScriptRoot\Reports\
    $Attachments = foreach ($file in $Attachments) { "$PSScriptRoot\Reports\$($file.name)" }
    
    Write-Host "Sending Email Reports..."
    Send-MailMessage `
        -To $emailTo `
        -From "Reports@onpointgroup.com" `
        -Subject "EmployeeID and Mobile Numbers" `
        -SmtpServer proclappexch01.minercorporation.com `
        -Body "Attached is this weeks reports." `
        -Attachments $Attachments `
        -Credential $credential
    
    Start-Sleep -s 5
    write-host "Deleting old attachments..."
    Remove-Item $Attachments
}
# WorkFlow---------------------------------------------------------------------------------------------------------

# Pull the data from AD and then export the data to CSV
write-host "Getting AD Objects...."
mkdir $PSSCriptRoot\Reports
$cellPhones = get-aduser -Filter {(employeeID -like "12827*") -and (mobile -ne "*")} -properties employeeiD,mobile -server $DomainControllerName `| select-object name,employeeID,mobile 
$cellPhones | Select-Object -Property @{label='employeeID';expression={$_.employeeID.Substring(7)}},mobile | Export-Csv -path "$PSScriptRoot\Reports\MobilePhones.csv" -NoTypeInformation 

# Send the email to the requested people
Send-CSVReports -emailTo $emailTo -credential $credential
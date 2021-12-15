Function Test-Cloudflare {
    #Enables script as Function
    
    <#
    .Synopsis
    Ping tests remote computer
    
    .Description
    Sends ICMP requests to a remote machine
    .Parameters
    -Computername <[]String>
        The name/IP address of the test computer
    
        Required?                       True
        Position?                       1
        Default value
        Accept pipeline input           False
        Accept wildcard Characters?     False
    
    
    
    .Example
    
    Example 1
    c:\>.\Test-Cloudflare - Computername Localhost
    
    Example 1: Test connectivity to specific computer
    
    
    Example 2
    C:\>.\Test-Cloudflare -Computername Localhost -output CSV
    
    Example 2: Test connectivity and write results to a specific format (CSV,TEST,Host)
    
    Example 3
    c:\>.\Test-Cloudflare -Computername Localhost -path c:\Temp
    
    Example 3: Test connectivity and change the path where results are saved
    
    .Notes
    
    Author: Dakota Denton-Velasquez
    Last Edit: 12/15/2021
    Version 1.0 - Initial Release of Test-Cloudflare
    Version 1.1 - Added for each loop and a switch construct
            - Enabled cmdlet binding and created function
    Version 1.2 - Added try/catch error handling
                - Uses pscustomobject instead of new-object
    Version 2.0 - Optimized script
                -Removed output handling
    #>
    
    [Cmdletbinding()]
    
    Param (
        [Parameter(mandatory=$true, ValueFromPipeline=$True)]
        [Alias('CN','Name')][String[]]$computername
        )#Close param block
    Process {
    
        foreach ($computer in $computername ) {

            Try {
                $params = @{
                    'Computername'=$computer
                    'ErrorAction'='Stop'
                }#end param
                $remotesession = New-PsSession @params
                Enter-PsSession $remotesession
                $TestCF = test-netconnection -computername 'one.one.one.one' -InformationLevel Detailed
        $obj =[PSCustomObject]@{
            'Computername' = $computer
            'PingSuccess' = $TestCF.PingSucceeded
            'NameResolve' = $TestCF.NameResolutionSucceeded
            'ResolvedAddresses' = $TestCF.ResolvedAddresses
        }
        $obj
    Exit-PsSession 
    Remove-PSSession $remotesession
    Write-Verbose "Finished Ping Test."
            } 
            Catch {
            Write-Host "Remote connection to $computer failed." -ForegroundColor red
            }
            
        }#Foreach block
    }#Function block
        
    


       
}
function Get-PipeResults{ #Enables script as Function
    
    <#
    .Synopsis
    Controls output format
    
    .Description
    Choose output style (Text, CSV, Host)
    .Parameters
    -Filename <[]String>
        The pipe Objects
    
        Required?                       False
        Position?                       1
        Default value
        Accept pipeline input           False
        Accept wildcard Characters?     False
    
    -Path <String>
        The name or path of the location to save output to. User home directory is default
    
        Required                        False
        Position?                       2
        Default value                   "$Env:USERPROFILE"
        Accept pipeline input?          False
        Accept wildcard Characters?     False
    
    -Output <String>
        Specifies the destination of output when the script is ran. Accepted inputs are:
        -Host (On-Screen)
        -Text (.txt file)
        -CSV (.csv file)
        
        Required?                        False
        Position?                        3
        Defaulte value                   Host
        Accept pipeline input            False
        Accept wildcard characters       False
    
    
    
    .Example
    
    Example 
    Get-Process -Name Windows | Get-PipeResults
    
    Example 1: Retrieve all Windows proceses as pipe objects
    
    
    .Notes
    
    Author: Dakota Denton-Velasquez
    Last Edit: 12/15/2021
    Version 1.0 - Initial Release of Get-PipeResults
    #>


    [CmdletBinding()]
    
        Param(
    [Parameter(Mandatory=$false, Valuefrompipeline=$true, ValueFromPipelineByPropertyName=$true)][object[]]$obj,
    [parameter(mandatory=$false)][string]$path = $env:USERPROFILE,
    [ValidateSet('Host','Text','CSV')][string]$output = "Host",
    [Parameter(mandatory=$false)][string]$Filename = "PipeResults"
        )#Close param block
    
        #Accepts byValue and byPropertyName pipeline input. Sets valid options for the output parameter and defaults output to host.
             Process{
                Switch($Output) {
                    "Text"{
                        $Object | Out-File $PathVariable\$FileName.txt
                        #Out files the object information into a text file.
                        Write-Verbose "Generating results file"
                        Start-Sleep -Seconds 1
                        Write-Verbose "Opening results"
                        Start-Sleep -Seconds 2
                        Notepad.exe $PathVariable\$FileName.txt
                        #Opens the text file.
                    }#Text
                    "CSV"{
                        Write-Verbose "Generating results as CSV"
                        Start-Sleep -Seconds 1
                        $Object | Export-CSV -Path $PathVariable\$FileName.csv
                        #Retrieves the output results and exports the contents to a CSV file.
                    }#CSV
                    "Host"{
                        Write-Verbose "Generating results file and displaying it to the screen"
                        Start-Sleep -Seconds 1
                        $Object
                        #Retrieves the output results and displays the contents to the screen.
                    }#Host
                }#Switch
        }#Process
        End{}#end process block
    }#Function    
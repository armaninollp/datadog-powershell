<#
.SYNOPSIS
    Module to assist in managing tags for your assets in Datadog

.DESCRIPTION
    Returns totals

.PARAMETER Headers
    Headers passed to Invoke-Request

.PARAMETER From
    Unix epoch

.EXAMPLE
    The example below does blah
    PS C:\> Example

.EXAMPLE
    Another example

.NOTES
    Author: Josh Kersey

#>


<#
.DESCRIPTION
    Returns totals

.PARAMETER Headers
    Headers passed to Invoke-Request

.PARAMETER From
    Unix epoch

.EXAMPLE
    The example below does blah
    PS C:\> Example

.EXAMPLE
    Another example

.NOTES
    Author: Josh Kersey
    Last Edit: yyyy-mm-dd
    Version 1.0 - initial release of blah
    Version 1.1 - update for blah

#>
function Get-DatadogHostTotal {
    Param ([Parameter(Mandatory = $true)]$Headers, [int]$From = $null)
    if ($From -lt 0) {
        Write-Error "From must be 0 or greater."
        return $null
    }
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    if ($null -eq $From) {
        return (Invoke-RestMethod -Method GET -Headers $Headers -Uri "https://api.datadoghq.com/api/v1/hosts/totals")
    }
    else {
        <# Action when all if and elseif conditions are false #>
        return (Invoke-RestMethod -Method GET -Headers $Headers -Uri "https://api.datadoghq.com/api/v1/hosts/totals?from=$From")
    }

}

<#

.DESCRIPTION
    Returns totals

.PARAMETER Headers
    Headers passed to Invoke-Request

.PARAMETER From
    Unix epoch

.EXAMPLE
    The example below does blah
    PS C:\> Example

.EXAMPLE
    Another example

.NOTES
    Author: Josh Kersey
    Last Edit: yyyy-mm-dd
    Version 1.0 - initial release of blah
    Version 1.1 - update for blah

#>
function Get-DatadogHostList {
    Param ([Parameter(Mandatory = $true)]$Headers,
        [switch]$IncludeMetadata = $false,
        [int]$Count = 1000,
        [int] $Start = 0,
        [string] $SortField = "name",
        [string] $SortDirection = "asc",
        [string] $Filter = $null)
    if ($SortDirection -ne "asc" -and $SortDirection -ne "desc") {
        Write-Error "SortDirection must be either 'asc' or 'desc'"
    }
    if ($Count -gt 1000 -or $Count -lt 0) {
        Write-Error "Count must be in range of 1-1000"
        return $null
    }
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $host_list = @()
    $loop_start = $Start
    do {
        if ($null -eq $Filter) {
            $UriString = "https://api.datadoghq.com/api/v1/hosts?count=$Count&include_meta_data=$IncludeMetadata&start=$loop_start&sort_dir=$SortDirection&sort_field=$SortField"
        }
        else {
            $UriString = "https://api.datadoghq.com/api/v1/hosts?count=$Count&include_meta_data=$IncludeMetadata&start=$loop_start&sort_dir=$SortDirection&sort_field=$SortField&filter=$Filter"
        }
        $result = Invoke-RestMethod -Method GET -Headers $Headers -Uri $UriString
        $host_list += $result.host_list
        $loop_start += $result.total_returned
    } while ($result.total_returned -ne 0)
    return $host_list
}

<#
.DESCRIPTION
    Uses ApplicationKey and ApiKey parameters

.PARAMETER Headers
    Headers passed to Invoke-Request

.PARAMETER From
    Unix epoch

.EXAMPLE
    The example below does blah
    PS C:\> Example

.EXAMPLE
    Another example

.NOTES
    Author: Josh Kersey
    Last Edit: yyyy-mm-dd
    Version 1.0 - initial release of blah
    Version 1.1 - update for blah

#>
function Set-DatadogAuthentication {
    Param([Parameter(Mandatory = $true)][string]$ApiKey, [string]$ApplicationKey = $null)
    $temp_headers = @{
        "DD-API-KEY"         = $ApiKey
        "DD-APPLICATION-KEY" = $ApplicationKey
        "Content-Type"       = "application/json"
    }
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    try {
        $tresult = (Invoke-RestMethod -Headers $temp_headers -Method GET -Uri 'https://api.datadoghq.com/api/v1/validate')
        if ($tresult.valid -eq "True") {
            return $temp_headers
        }
        else {
            return $false
        }
    }
    catch {
        {
            return $false
        }
    }

}

function Get-DatadogTags {
    Param([Parameter(Mandatory = $true)]$Headers)
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    try {
        $tresult = (Invoke-RestMethod -Headers $Headers -Method GET -Uri 'https://api.datadoghq.com/api/v1/tags/hosts')
        return $tresult
        
    }
    catch {
        return $null
    }

}


function Get-DatadogHostTags {
    Param([Parameter(Mandatory = $true)]$Headers, [string]$Name)
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    try {
        $tresult = (Invoke-RestMethod -Headers $Headers -Method GET -Uri "https://api.datadoghq.com/api/v1/tags/hosts/$Name")
        return $tresult.tags
        
    }
    catch {
        return $null
    }

}

function Export-DatadogTagsByHost {
    Param([string]$Path = ".", 
        [string[]]$Sources = @("Users"),
        [string]$Format = "Both")
    Begin {
        if ($Format -ne "Json" -and $Format -ne "Text" -and $Format -ne "Both") {
            Write-Error "Format must be either 'Json', 'Text', or 'Both'"
        }
        #Write-Host "Exporting data"
    }
    Process {
        #Write-Host $fname
        if ($Format -eq "Json" -or $Format -eq "Both") {
        ($_.tags_by_source | ConvertTo-Json) > $Path\$($_.name).json

        }

        foreach ($tag_source in $Sources) {
            #Write-Host $tag_source
            foreach ($tag in $_.tags_by_source.$tag_source) {
                $fname = "$($_.name).$tag_source.txt"
                Write-Host $fname
            }
            #Write-Host $tag_source

            # foreach ($tag_string in $tag_source) {
            #     $fname = "$($_.name).$tag_source.txt"
            #     $newfile_result = (New-Item -Path $Path -Name $fname -ItemType File -Force)
            #     if ($null -eq $newfile_result) {
            #         Write-Error "Unable to create file"
            #     }
            #     Write-Host "Adding $tag_string to $Path/$($fname)"
            #     Add-Content -Path "$Path/$($fname)" -Value "$tag_string"
            # }
        }
        #Write-Host
    }
    End {
        #Write-Host "Complete"
    }
}

function Export-DatadogTagsByTag {
    Param([string]$Path = "./",
        [string]$Format = "Json")
    Begin {
        Write-Host "Exporting data"
    }
    Process {
        Write-Host -NoNewLine $_.host_name
    }
    End {
        Write-Host "Complete"
    }
}
Export-ModuleMember -Function Set-DatadogAuthentication
Export-ModuleMember -Function Export-DatadogTagsByHost
Export-ModuleMember -Function Get-DatadogHostList
Export-ModuleMember -Function Get-DatadogHostTotal
Export-ModuleMember -Function Get-DatadogHostTags
Export-ModuleMember -Function Get-DatadogTagsByHost

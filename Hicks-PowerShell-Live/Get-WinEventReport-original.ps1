#requires -version 5.1

<#
This version of the function has been enhanced and revised
beyond what I originally created in my presentation.
#>
Function Get-WinEventReport {
    [cmdletbinding()]
    [OutputType('psEventLogReport')]
    [alias('wer')]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = 'Specify the name of an eventlog to query. Wildcards are allowed.')]
        [ValidateNotNullOrEmpty()]
        [String[]]$LogName,

        [Parameter(HelpMessage = "Specify the number of event log entries to query. The default is the complete log.")]
        [Int]$MaxEvents,

        [Parameter(ValueFromPipeline,HelpMessage = 'Specify the name of a computer to query. The default is the local computer.')]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName = $env:COMPUTERNAME,

        [Parameter(HelpMessage = 'Specify the credentials to use to query a remote computer.')]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential
    )

    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Running under PowerShell version $($PSVersionTable.PSVersion)"
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Using PowerShell host $($Host.Name)"

        #initialize an empty list to hold the custom objects
        $list = [System.Collections.Generic.List[object]]::new()

        #capture the current date time to be used in the object output
        $ReportDate = Get-Date
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Processing eventlog $LogName on $ComputerName"
        Try {
            #splat the bound parameters from this function to Get-WinEvent
            $EventLogEntries = Get-WinEvent @PSBoundParameters  -ErrorAction Stop | Group-Object -Property ProviderName
        } #try
        Catch {
            Write-Warning "[$((Get-Date).TimeOfDay) CATCH  ] Unable to query eventlog $LogName on $ComputerName. $($_.Exception.Message)"
        } #catch

        If ($EventLogEntries) {
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Found $($EventLogEntries.count) eventlog sources"
            $EventLogEntries | ForEach-Object {
                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Processing $($_.count) entries for event source $($_.Name)"
                $info = $_.Group | Where-Object { $_.LevelDisplayName -eq 'Information' }
                $err = $_.Group | Where-Object { $_.LevelDisplayName -eq 'Error' }
                $warn = $_.Group | Where-Object { $_.LevelDisplayName -eq 'Warning' }
                #get static properties from the first eventlog entry
                $Log = $_.group[0].LogName
                $MachineName = $_.group[0].MachineName
                #write a custom object to the pipeline with a defined typename
                $obj = [PSCustomObject]@{
                    PSTypeName   = 'psEventLogReport'
                    Source       = $_.Name
                    Total        = $_.Count
                    Error        = $err.count
                    Warning      = $warn.count
                    Information  = $info.count
                    LogName      = $Log
                    Computername = $MachineName
                    ReportDate   = $ReportDate
                } #close PSCustomObject

                #add the custom object to the list
                $list.Add($obj)
            }
        } #if event log entries found
    } #process

    End {
        if ($List.Count -gt 0) {
            Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Writing $($list.count) objects to the pipeline"
            $list | Sort-Object Computername, LogName, Source
        }
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end

} #close Get-WinEventReport

#define an alias property of EventSource for the Source property
Update-TypeData -TypeName psEventLogReport -MemberType AliasProperty -MemberName EventSource -Value Source -Force
#define a default set of properties to display
Update-TypeData -TypeName psEventLogReport -DefaultDisplayPropertySet Source, Total, Error, Warning, Information, LogName -Force

#load the custom formatting file
Update-FormatData -AppendPath $PSScriptRoot\psEventLogReport.format.ps1xml

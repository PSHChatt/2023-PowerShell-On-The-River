#requires -version 5.1

<#
This version of the function has been enhanced and revised
beyond what I originally created in my presentation.

This version uses PowerShell remoting to scale the function.
Remoting runs about 3X faster than the original version.
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

        [Parameter(HelpMessage = 'Specify the number of event log entries to query. The default is the complete log.')]
        [Int]$MaxEvents,

        [Parameter(ValueFromPipeline, HelpMessage = 'Specify the name of a computer to query. The default is the local computer.')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME,

        [Parameter(HelpMessage = 'Specify the credentials to use to query a remote computer.')]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential,

        #this was added to support remoting
        [Parameter(HelpMessage = "Specifies the maximum number of concurrent connections that can be established to run this command. If you omit this parameter or
        enter a value of 0, the default value, 32, is used. The max value is 64.")]
        [ValidateRange(0, 64)]
        [Int]$ThrottleLimit = 32
    )

    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Running under PowerShell version $($PSVersionTable.PSVersion)"
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Using PowerShell host $($Host.Name)"

        #initialize an empty list to hold the custom objects
        $list = [System.Collections.Generic.List[object]]::new()

        $tmpPS = [System.Collections.Generic.List[System.Management.Automation.Runspaces.PSSession]]::new()
        #capture the current date time to be used in the object output
        $ReportDate = Get-Date

        #define a hashtable of parameters to splat to New-PSSession
        $sessionSplat = @{
            ErrorAction = 'Stop'
        }
        if ($Credential) {
            Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Using credentials for $($Credential.UserName)"
            $sessionSplat.Add('Credential', $Credential)
        }

        #define a scriptblock to run on the remote computer
        $sb = {
            #inherit the local verbose preference to the remote session
            $VerbosePreference = $using:VerbosePreference
            $splat = @{
                LogName = $using:LogName
            }

            If ($using:MaxEvents -gt 0) {
                $splat.Add('MaxEvents', $using:MaxEvents)
            }
            Write-Verbose "[$((Get-Date).TimeOfDay) REMOTE ] Processing eventlog $($splat.LogName.ToUpper()) on $($env:COMPUTERNAME)"
            $EventLogEntries = Get-WinEvent @splat | Group-Object -Property ProviderName
            Write-Verbose "[$((Get-Date).TimeOfDay) REMOTE ] Found $($EventLogEntries.count) eventlog sources"
            $EventLogEntries | ForEach-Object {
                Write-Verbose "[$((Get-Date).TimeOfDay) REMOTE ] Processing $($_.count) entries for event source $($_.Name)"
                $info = $_.Group | Where-Object { $_.LevelDisplayName -eq 'Information' }
                $err = $_.Group | Where-Object { $_.LevelDisplayName -eq 'Error' }
                $warn = $_.Group | Where-Object { $_.LevelDisplayName -eq 'Warning' }
                #get static properties from the first eventlog entry
                $Log = $_.group[0].LogName
                #I am not using the machine name from the event log because
                #the computer name might have changed
                $MachineName = $env:COMPUTERNAME

                #write a custom object to the pipeline with a defined typename
                [PSCustomObject]@{
                    PSTypeName   = 'psEventLogReport'
                    Source       = $_.Name
                    Total        = $_.Count
                    Error        = $err.count
                    Warning      = $warn.count
                    Information  = $info.count
                    LogName      = $Log
                    Computername = $MachineName
                    ReportDate   = $using:ReportDate
                } #close PSCustomObject
            } #foreach

        } #close scriptblock
    } #begin

    Process {
        #create a temporary PSSession to each computer
        Try {
            foreach ($computer in $Computername) {
                Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Creating temporary PSSession to $($Computer.ToUpper())"
                $tmpPS.Add($(New-PSSession @sessionSplat -ComputerName $Computer))
            }
        }
        Catch {
            Write-Warning "[$((Get-Date).TimeOfDay) CATCH  ] Unable to create a PSSession to $ComputerName. $($_.Exception.Message)"
        } #catch
} #process

End {
    #process all of the temporary PSSessions
    Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Processing $($tmpPS.Count) PSSessions"
    Invoke-Command -ScriptBlock $sb -Session $tmpPS -ThrottleLimit $ThrottleLimit -HideComputerName | ForEach-Object {
        #add each remote output to the local list
        $List.Add($_)
    }
    if ($List.Count -gt 0) {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Writing $($list.count) objects to the pipeline"
        $list | Sort-Object Computername, LogName, Source
        }
    #remove the temporary PSSessions
    if ($tmpPS.Count -gt 0) {
        Remove-PSSession -Session $tmpPS
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

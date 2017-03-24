<#

New-ModuleManifest `
-Path "C:\Users\pa1re\OneDrive\WindowsPowerShell\Modules\PoShHrdUtils\PoShHrdUtils.psd1" `
-RootModule "C:\Users\pa1re\OneDrive\WindowsPowerShell\Modules\PoShHrdUtils\PoShHrdUtils.psm1" `
-Author 'Reginald Baalbergen, The PA1REG' `
-CompanyName 'Radio Amateur' `
-Copyright '(c)2017 Reginald Baalbergen (PA1REG)' `
-Description 'Ham Radio Deluxe Utilities, Download and Update silent' `
-ModuleVersion 1.2 `
-PowerShellVersion 5.0 `
-FunctionsToExport 'Update-HamRadioDeluxe', 'Install-HamRadioDeluxe' `
-AliasesToExport 'UH', 'IH' `
-ProjectUri 'https://github.com/PA1REG/PoShHrdUtils' `
-HelpInfoUri 'https://github.com/PA1REG/PoShHrdUtils/blob/master/readme.md' `
-ReleaseNotes 'Initial Release.'
 
  
https://dfinke.github.io/2016/Quickly-Install-PowerShell-Modules-from-GitHub/
get-command -Module InstallModuleFromGitHub

Install-Module -Name InstallModuleFromGitHub -RequiredVersion 0.3
Install-ModuleFromGitHub -GitHubRepo /PA1REG/PoShHrdUtils


#>


function Get-HRDInstallLocation
{
 [CmdletBinding(
 )]
    param
    (
    )
    begin
    {
      Write-Verbose "Start Module : [$($MyInvocation.MyCommand)] *************************************"
      $HKLMRegistryKey = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
      $ProgramName = "Ham Radio Deluxe"
      
      Try 
      {
        Write-Verbose "Get Installation Location for : $ProgramName"
        $InstallLocation = Get-ItemProperty $HKLMRegistryKey |where {$_.displayname -eq $ProgramName} | Select -expandproperty InstallLocation
        $InstallLocation = $InstallLocation | Sort-Object -Unique
        if ($InstallLocation)
        {
          Write-Verbose "Found Installation Location ($InstallLocation) for : $ProgramName"
          Return $InstallLocation
        } else
        {
          Write-Verbose "Could not find Installation Location ($InstallLocation) for : $ProgramName"
          Return $null
        }
      } Catch 
      {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Verbose "Unable to get Installation Location for : $ProgramName ($ErrorMessage, $FailedItem)"
        Return $null
      }
      Write-Verbose "End Module  : [$($MyInvocation.MyCommand)] *************************************"
    }     
}

function Get-FileVersion
{
 [CmdletBinding(
 )]
    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $Path
        
    )
    begin
    {
      Write-Verbose "Start Module : [$($MyInvocation.MyCommand)] *************************************"
      Try 
      {
        $VersionInfo = (Get-Item $Path).VersionInfo.FileVersion
#        $VersionInfo = (Get-Item $Path).VersionInfo.ProductVersion
        $VersionInfo = $VersionInfo.Trim()
        Write-Verbose "Version for : $Path is $VersionInfo"
        Return $VersionInfo
      } Catch 
      {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Verbose "Unable to get Version Info for : $Path ($ErrorMessage, $FailedItem)"
        Return $null
      }
      Write-Verbose "End Module  : [$($MyInvocation.MyCommand)] *************************************"
    }     
}

function Get-HrdInstalled
{
    [CmdletBinding()]
    param
    (
    )
    begin
    { 
      $ProgramName = "Ham Radio Deluxe"
      Write-Verbose "Start Module : [$($MyInvocation.MyCommand)] *************************************"
      $HrdInstallationRegistry = 'HKCU:\software\Amateur Radio\HamRadioDeluxe\'
      if (Test-Path -Path $HrdInstallationRegistry)
      {
        Write-Verbose "Detected Installation : $ProgramName"
        Write-Host "Detected Installation : $ProgramName" -ForegroundColor Green
      } else 
      {
        Write-Verbose "Could not detect Installation : $ProgramName"
        Write-Host "Could not detect Installation : $ProgramName" -ForegroundColor Green
        Write-Error -Message "Error: $ProgramName not installed." -Category NotInstalled
        Throw 'Install manually $ProgramName first.'
      }
      Write-Verbose "End Module  : [$($MyInvocation.MyCommand)] *************************************"
    }
}

function Get-HrdSetupExe
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$false)]
        [String] $DownloadFile
    )
    begin
    {
      Write-Verbose "Start Module : [$($MyInvocation.MyCommand)] *************************************"
      $ProgramName = "Ham Radio Deluxe"
      $HrdSetupURL = 'http://www.hrdsoftwarellc.com/files/setup.exe'
#      $DownloadDirectory = "$env:USERPROFILE/downloads"
      $start_time = Get-Date

      Try 
      {
        Write-Host "Start Downloading $ProgramName from $HrdSetupURL" -ForegroundColor Green
        $DownLoadClient = new-object System.Net.WebClient
        $DownLoadClient.DownloadFile("$HrdSetupURL","$DownloadFile")
        #Invoke-WebRequest $HrdSetupURL -OutFile "$DownloadFile" 
        Write-Host "$ProgramName downloaded succesfully to $DownloadDirectory in $((Get-Date).Subtract($start_time).Seconds) second(s)" -ForegroundColor Green  
        Return $DownloadFile  
      } Catch 
      {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Verbose "Unable to download file $DownloadFile from $HrdSetupURL ($ErrorMessage, $FailedItem)"
        Return $null
      }
    }
}


function Install-Hrd
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$false)]
        [String] $SetupFile,
        
        [Parameter(Position=1, Mandatory=$false)]
        [Switch] $Silent

    )
    begin
    {
      Write-Verbose "Start Module : [$($MyInvocation.MyCommand)] *************************************"
      $ProgramName = "Ham Radio Deluxe"
      $Delaytime = 5
      $TimeElaped = 0
      $TimeOut = 500

      Try 
      {
        Write-Host "Start $ProgramName from $SetupFile" -ForegroundColor Green
        Write-Verbose "Start $SetupFile"
        if ($Silent)
        {
          Write-Verbose "Start $SetupFile in Silent Mode."
          Start-Process -FilePath "$SetupFile" -ArgumentList "/s"
        } else
        {
          Write-Verbose "Start $SetupFile NOT in Silent Mode."
          Start-Process -FilePath "$SetupFile" 
        }

        Write-Verbose "Start installation $SetupFile"
      } Catch 
      {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Verbose "Unabe to start installation $SetupFile ($ErrorMessage, $FailedItem)"
       BREAK
      }

      $ProcessName="Setup*"
      Do 
      {
        If (!(Get-Process $ProcessName -ErrorAction SilentlyContinue)) 
        {
             Write-Host "Waiting for $ProgramName Installation starts ($SetupFile)" -ForegroundColor Cyan
             Start-Sleep -Seconds $Delaytime
        } Else 
        {
           Write-Host "Installation of $ProgramName has started" -ForegroundColor Green 
           While (Get-Process $ProcessName -ErrorAction SilentlyContinue) 
           {
               Write-Host "$ProgramName, still installing.($TimeElaped)" -ForegroundColor Blue
               Start-Sleep -Seconds $Delaytime
               $TimeElaped =+ $TimeElaped + $Delaytime
               if ($TimeElaped -ge $TimeOut)
               {
                 Write-Host "Timeout : Installation takes too long ( > $TimeOut sec.)" -ForegroundColor Red
                 BREAK
               }
           }
           Write-Host "Installation of $ProgramName succeeded"  -ForegroundColor Green ; $Status = 'Done'
        }
      } 
      Until ($Status)
      Write-Verbose "End Module  : [$($MyInvocation.MyCommand)] *************************************"
    }
}


function Update-HamRadioDeluxe
{
    <#
        .SYNOPSIS
            Function to download and install Ham Radio Deluxe.
        .DESCRIPTION
            This function download and installs Ham Radio Deleuxe with optional parameters for control.
        .PARAMETER DownloadPath
            Specify this parameter if you wish to download the Setup.exe to an other location.
            Notes: 
                * Default path = %USERPROFILE%/Downloads
        .PARAMETER SetupFile
            If you want to install from an already downloaded the Setup.exe, specify the path and Setup file. 
        .PARAMETER Force
            Specify to disable the already installed and downloaded version check, setup will run.
        .EXAMPLE
            PS> Update-HamRadioDeluxe 

            This example download the Setup.exe to %USERPROFILE%/Downloads and runs the Setup.
        .EXAMPLE
            PS> Update-HamRadioDeluxe -DownloadPath "C:\Temp\"

            This example download the Setup.exe to C:\Temp and runs the Setup.
        .EXAMPLE
            PS> Update-HamRadioDeluxe -SetupFile "C:\Temp\Setup 6.4.exe"

            This example runs the from "C:\Temp\Setup 6.4.exe".
        .EXAMPLE
            PS> Update-HamRadioDeluxe -Force

            This example download the Setup.exe to %USERPROFILE%/Downloads and runs the Setup. Version checking is disabeld.
        .EXAMPLE
            PS> Update-HamRadioDeluxe -SetupFile "C:\Temp\Setup 6.4.exe" -Force

            This example runs the from "C:\Temp\Setup 6.4.exe". Version checking is disabeld.
        .INPUTS
        .OUTPUTS
            $null
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$false)]
        [String] $DownloadPath,

        [Parameter(Position=1, Mandatory=$false)]
        [String] $SetupFile,
  
        [Parameter(Position=2, Mandatory=$false)]
        [Switch] $Force
  
    )
    begin
    {
      Write-Verbose "Start Module : [$($MyInvocation.MyCommand)] *************************************"
      $ProgramName = "Ham Radio Deluxe"
      $ProgramVersion = "$((Get-Module PoShHrdUtils).Version.Major) . $((Get-Module PoShHrdUtils).Version.Minor) . $((Get-Module PoShHrdUtils).Version.Revision)"
      $ProgramVersion = $ProgramVersion.Trim()
      Write-Host "$ProgramName version : $ProgramVersion" -ForegroundColor Green
      
      $HrdInstallLocation = Get-HRDInstallLocation
      if ($HrdInstallLocation)
      {
        Write-Host "$ProgramName is currently Installed in : $HrdInstallLocation" -ForegroundColor Green
        $HrdInstallVersion = Get-FileVersion -Path "$HrdInstallLocation/HamRadioDeluxe.exe"
        if ($HrdInstallVersion)
        {
          Write-Host "Current Installed Version : $HrdInstallVersion" -ForegroundColor Green
        } else
        {
          Write-Host "Failed to detect version installation, unable to update" -ForegroundColor Red
          BREAK
        }  
      } else
      {
        Write-Host "Failed to detect current installation" -ForegroundColor Red
        BREAK
      }  

      if ($DownloadPath)
      {
        $DownloadDirectory = $DownloadPath
      } else
      {
        $DownloadDirectory = "$env:USERPROFILE\Downloads"
      }
      
      if ($SetupFile)
      {
          Write-Host "Install Setup file choosen $SetupFile" -ForegroundColor Green
          $HrdDownloadedVersion = Get-FileVersion -Path "$SetupFile"
          $DownloadSetupFile = $SetupFile
          if ($HrdDownloadedVersion)
          {
            Write-Host "To install Version : $HrdDownloadedVersion" -ForegroundColor Green
          } else
          {
            Write-Host "Failed to detect version installation" -ForegroundColor Red
            BREAK
          }  
      } else
      {
        $DownloadSetupFile = "$DownloadDirectory\Setup.exe"  
        if (Get-HrdSetupExe -DownloadFile $DownloadSetupFile)
        {
          #Write-Host "Successfully Downloaded" -ForegroundColor Green
          $HrdDownloadedVersion = Get-FileVersion -Path "$DownloadSetupFile"
          if ($HrdDownloadedVersion)
          {
            Write-Host "Downloaded Version : $HrdDownloadedVersion" -ForegroundColor Green
          } else
          {
            Write-Host "Failed to detect version installation, unable to update" -ForegroundColor Red
          BREAK
          }  
        } else
        {
          Write-Host "Failed to download" -ForegroundColor Red
          BREAK
        }  
      }
      
      if ($HrdInstallVersion -eq $HrdDownloadedVersion -and -not $Force)
      {
        Write-Host "Setup version is the same as installed version, no need to update." -ForegroundColor Red
      } else
      {
        Write-Host "Startup Setup : $DownloadSetupFile" -ForegroundColor Green
        Install-Hrd -SetupFile $DownloadSetupFile
      }  

      Write-Verbose "End Module  : [$($MyInvocation.MyCommand)] *************************************"
    }
}


function Install-HamRadioDeluxe
{
    <#
        .SYNOPSIS
            Function to download and install Ham Radio Deluxe.
        .DESCRIPTION
            This function download and installs Ham Radio Deleuxe with optional parameters for control.
        .PARAMETER DownloadPath
            Specify this parameter if you wish to download the Setup.exe to an other location.
            Notes: 
                * Default path = %USERPROFILE%/Downloads
        .PARAMETER SetupFile
            If you want to install from an already downloaded the Setup.exe, specify the path and Setup file. 
        .PARAMETER Force
            Specify to disable the already installed and downloaded version check, setup will run.
        .EXAMPLE
            PS> Update-HamRadioDeluxe 

            This example download the Setup.exe to %USERPROFILE%/Downloads and runs the Setup.
        .EXAMPLE
            PS> Update-HamRadioDeluxe -DownloadPath "C:\Temp\"

            This example download the Setup.exe to C:\Temp and runs the Setup.
        .EXAMPLE
            PS> Update-HamRadioDeluxe -SetupFile "C:\Temp\Setup 6.4.exe"

            This example runs the from "C:\Temp\Setup 6.4.exe".
        .EXAMPLE
            PS> Update-HamRadioDeluxe -Force

            This example download the Setup.exe to %USERPROFILE%/Downloads and runs the Setup. Version checking is disabeld.
        .EXAMPLE
            PS> Update-HamRadioDeluxe -SetupFile "C:\Temp\Setup 6.4.exe" -Force

            This example runs the from "C:\Temp\Setup 6.4.exe". Version checking is disabeld.
        .INPUTS
        .OUTPUTS
            $null
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$false)]
        [String] $DownloadPath,

        [Parameter(Position=1, Mandatory=$false)]
        [String] $SetupFile,
  
        [Parameter(Position=2, Mandatory=$false)]
        [Switch] $Force
  
    )
    begin
    {
      Write-Verbose "Start Module : [$($MyInvocation.MyCommand)] *************************************"
      $ProgramName = "Ham Radio Deluxe"
      $ProgramVersion = "$((Get-Module PoShHrdUtils).Version.Major) . $((Get-Module PoShHrdUtils).Version.Minor) . $((Get-Module PoShHrdUtils).Version.Revision)"
      $ProgramVersion = $ProgramVersion.Trim()
      Write-Host "$ProgramName version : $ProgramVersion" -ForegroundColor Green
      
 
      if ($DownloadPath)
      {
        $DownloadDirectory = $DownloadPath
      } else
      {
        $DownloadDirectory = "$env:USERPROFILE\Downloads"
      }
      
      if ($SetupFile)
      {
          Write-Host "Install Setup file choosen $SetupFile" -ForegroundColor Green
          $HrdDownloadedVersion = Get-FileVersion -Path "$SetupFile"
          $DownloadSetupFile = $SetupFile
          if ($HrdDownloadedVersion)
          {
            Write-Host "To install Version : $HrdDownloadedVersion" -ForegroundColor Green
          } else
          {
            Write-Host "Failed to detect version installation" -ForegroundColor Red
            BREAK
          }  
      } else
      {
        $DownloadSetupFile = "$DownloadDirectory\Setup.exe"  
        if (Get-HrdSetupExe -DownloadFile $DownloadSetupFile)
        {
          #Write-Host "Successfully Downloaded" -ForegroundColor Green
          $HrdDownloadedVersion = Get-FileVersion -Path "$DownloadSetupFile"
          if ($HrdDownloadedVersion)
          {
            Write-Host "Downloaded Version : $HrdDownloadedVersion" -ForegroundColor Green
          } else
          {
            Write-Host "Failed to detect version installation, unable to update" -ForegroundColor Red
          BREAK
          }  
        } else
        {
          Write-Host "Failed to download" -ForegroundColor Red
          BREAK
        }  
      }
      
      Write-Host "Startup Setup : $DownloadSetupFile" -ForegroundColor Green
      Install-Hrd -SetupFile $DownloadSetupFile

      Write-Verbose "End Module  : [$($MyInvocation.MyCommand)] *************************************"
    }
}


Export-ModuleMember -function Update-HamRadioDeluxe -alias UH
Export-ModuleMember -function Install-HamRadioDeluxe -alias IH



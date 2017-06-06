Configuration SetApplockerRules {
    param
    (
        [Parameter(Mandatory)]
        [String]$MachineName
    )
    Node $MachineName
    {
        Service AppIDsvc {
            Name = 'AppIDSvc'
            StartupType = 'Automatic'
            State = 'Running'
            BuiltinAccount = 'LocalService'
            DependsOn = "[File]XMLPol","[Script]ApplyLocalApplockerPol"

        }
        Script ApplyLocalApplockerPol {
            GetScript = {
                @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result  = ([xml](Get-AppLockerPolicy -Effective -Xml)).InnerXML
                }
            }
            SetScript = {
                Set-AppLockerPolicy -XMLPolicy 'C:\windows\temp\polApplocker.xml'
            }
            TestScript = { 
                if(
                Compare-Object -ReferenceObject  ([xml](Get-AppLockerPolicy -Effective -Xml)).InnerXML `
                               -DifferenceObject ([xml](Get-Content 'C:\windows\temp\polApplocker.xml')).InnerXml
                ) {
                    return $false
                } else {
                    return $true
                }
            }
            DependsOn = "[File]XMLPol"
        }
        File  XMLPol {
            DestinationPath = 'C:\windows\temp\polApplocker.xml'
            Ensure = 'Present';
            Force = $true
            Contents = @'        
<AppLockerPolicy Version="1">
  <RuleCollection Type="Appx" EnforcementMode="Enabled" />
  <RuleCollection Type="Dll" EnforcementMode="NotConfigured" />
  <RuleCollection Type="Exe" EnforcementMode="Enabled">
    <FilePathRule Id="921cc481-6e17-4653-8f75-050b80acca20" Name="(Default Rule) All files located in the Program Files folder" Description="Allows members of the Everyone group to run applications that are located in the Program Files folder." UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions>
        <FilePathCondition Path="%PROGRAMFILES%\*" />
      </Conditions>
    </FilePathRule>
    <FilePathRule Id="a61c8b2c-a319-4cd0-9690-d2177cad7b51" Name="(Default Rule) All files located in the Windows folder" Description="Allows members of the Everyone group to run applications that are located in the Windows folder." UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions>
        <FilePathCondition Path="%WINDIR%\*" />
      </Conditions>
    </FilePathRule>
    <FilePathRule Id="fd686d83-a829-4351-8ff4-27c7de5755d2" Name="(Default Rule) All files" Description="Allows members of the local Administrators group to run all applications." UserOrGroupSid="S-1-5-32-544" Action="Allow">
      <Conditions>
        <FilePathCondition Path="*" />
      </Conditions>
    </FilePathRule>
    <FilePublisherRule Id="f216d2ae-b7eb-484e-8ef5-297c961577c3" Name="Program Files: MICROSOFT® WINDOWS® OPERATING SYSTEM signed by O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions>
        <FilePublisherCondition PublisherName="O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" ProductName="MICROSOFT® WINDOWS® OPERATING SYSTEM" BinaryName="*">
          <BinaryVersionRange LowSection="6.3.0.0" HighSection="*" />
        </FilePublisherCondition>
      </Conditions>
    </FilePublisherRule>
    <FilePublisherRule Id="df9784b2-bd11-4e06-8cd5-9adf604529ac" Name="Program Files: MICROSOFT MONITORING AGENT signed by O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions>
        <FilePublisherCondition PublisherName="O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" ProductName="MICROSOFT MONITORING AGENT" BinaryName="*">
          <BinaryVersionRange LowSection="8.0.0.0" HighSection="*" />
        </FilePublisherCondition>
      </Conditions>
    </FilePublisherRule>
    <FilePublisherRule Id="9436f91a-d2da-45e7-bfdb-7faae7db71c3" Name="Program Files: MICROSOFT® VISUAL STUDIO® 2013 signed by O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions>
        <FilePublisherCondition PublisherName="O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" ProductName="MICROSOFT® VISUAL STUDIO® 2013" BinaryName="*">
          <BinaryVersionRange LowSection="12.0.0.0" HighSection="*" />
        </FilePublisherCondition>
      </Conditions>
    </FilePublisherRule>
    <FilePublisherRule Id="529fc03c-5568-48a7-8faa-346d74e8aa35" Name="Program Files: MICROSOFT SYSTEM CENTER ONLINE signed by O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions>
        <FilePublisherCondition PublisherName="O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" ProductName="MICROSOFT SYSTEM CENTER ONLINE" BinaryName="*">
          <BinaryVersionRange LowSection="1.10.0.0" HighSection="*" />
        </FilePublisherCondition>
      </Conditions>
    </FilePublisherRule>
    <FilePublisherRule Id="f8819956-50ed-4954-bb77-2d62c67e4869" Name="Program Files: PREMIER PROACTIVE ASSESSMENT SERVICES signed by O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions>
        <FilePublisherCondition PublisherName="O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" ProductName="PREMIER PROACTIVE ASSESSMENT SERVICES" BinaryName="*">
          <BinaryVersionRange LowSection="2.0.0.0" HighSection="*" />
        </FilePublisherCondition>
      </Conditions>
    </FilePublisherRule>
    <FilePublisherRule Id="79ebf396-b3e0-468e-8f2a-77aa3a4386b3" Name="Program Files: HYBRID SERVICE MANAGEMENT AUTOMATION signed by O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions>
        <FilePublisherCondition PublisherName="O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" ProductName="HYBRID SERVICE MANAGEMENT AUTOMATION" BinaryName="*">
          <BinaryVersionRange LowSection="7.2.0.0" HighSection="*" />
        </FilePublisherCondition>
      </Conditions>
    </FilePublisherRule>
    <FilePublisherRule Id="841b0342-7a75-4ddb-9dc9-e3bc8ecf05f4" Name="Program Files: INTERNET EXPLORER signed by O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions>
        <FilePublisherCondition PublisherName="O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" ProductName="INTERNET EXPLORER" BinaryName="*">
          <BinaryVersionRange LowSection="11.0.0.0" HighSection="*" />
        </FilePublisherCondition>
      </Conditions>
    </FilePublisherRule>
  </RuleCollection>
  <RuleCollection Type="Msi" EnforcementMode="Enabled" />
  <RuleCollection Type="Script" EnforcementMode="Enabled" />
</AppLockerPolicy>
'@
        }


        
    }
}

<#if (-not(test-path -Path C:\DSC -PathType Container)){
    mkdir C:\DSC
}
# Compile the configuration file to a MOF format
localApplockerDSCConfig -OutputPath C:\DSC

# Run the configuration on localhost
Start-DscConfiguration -Path C:\DSC  -ComputerName localhost -Verbose -Force -Wait#>
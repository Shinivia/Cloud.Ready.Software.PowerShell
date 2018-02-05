function Clean-NAVCustomContainerAppsOnDockerHost {
    param(
        [Parameter(Mandatory = $true)]
        [String] $DockerHost,
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential] $DockerHostCredentials,
        [Parameter(Mandatory = $false)]
        [Switch] $DockerHostUseSSL,
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.Remoting.PSSessionOption] $DockerHostSessionOption,
        [Parameter(Mandatory = $true)]
        [String] $ContainerName
    )

    Invoke-Command -ComputerName $DockerHost -UseSSL:$DockerHostUseSSL -Credential $DockerHostCredentials -SessionOption $DockerHostSessionOption -ScriptBlock {
        param(
            $ContainerName
        )
        
        $Session = Get-NavContainerSession -containerName $ContainerName
        Invoke-Command -Session $Session -ScriptBlock {
       
            $Apps = Get-NAVAppInfo -ServerInstance NAV | Where Publisher -ne 'Microsoft'
                
            foreach ($App in $Apps){
                $App | Uninstall-NAVApp -DoNotSaveData
                $App | Sync-NAVApp -ServerInstance NAV -Mode Clean -force
                $App | UnPublish-NAVApp            
                Sync-NAVTenant -ServerInstance NAV -Tenant Default -Mode ForceSync -force    
            }       
        }  
    }   -ArgumentList $ContainerName
}
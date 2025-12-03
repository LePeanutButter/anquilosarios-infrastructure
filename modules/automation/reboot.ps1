<#
================================================================================
Script Name   : reboot.ps1
Description   : Restart a virtual machine in Azure using an Automation Account's
                managed identity. This PowerShell script is designed to be
                executed as an Azure Automation Runbook.
# Author      : LePeanutButter, Lanapequin, shiro
Created       : 2025-11-29
License       : MIT License
================================================================================

Parameters:
------------
$ResourceGroupName - (String, Mandatory) The name of the Azure Resource Group
                     containing the target virtual machine.
$VMName            - (String, Mandatory) The name of the virtual machine to
                     restart.

Behavior:
----------
1. Authenticates to Azure using the Automation Account's system-assigned managed identity.
2. Sets the current Azure context to the subscription in which the Automation Account exists.
3. Outputs a log message indicating which VM and Resource Group are being restarted.
4. Initiates a restart of the specified virtual machine as a background job.
#>
param(
    [parameter(Mandatory = $true)]
    [String]$ResourceGroupName,

    [parameter(Mandatory = $true)]
    [String]$VMName
)

#-------------------------------------------------------------------------------
# Authenticate to Azure using the Automation Account's Managed Identity
#-------------------------------------------------------------------------------
Connect-AzAccount -Identity
Set-AzContext -SubscriptionId (Get-AzContext).Subscription.Id

#-------------------------------------------------------------------------------
# Log output indicating which VM will be restarted
#-------------------------------------------------------------------------------
Write-Output "Restarting VM: $VMName in Resource Group: $ResourceGroupName"

#-------------------------------------------------------------------------------
# Restart the virtual machine as a background job
#-------------------------------------------------------------------------------
Restart-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName -Force -AsJob

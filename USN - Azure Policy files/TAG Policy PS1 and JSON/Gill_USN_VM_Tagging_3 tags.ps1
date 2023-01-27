#Visual Studio Code was used to author 
#Steps 1-5 will be run 1 time for customer
#Steps 6-8 will be run for each new initiative and then assignment which needs to have values modified in STEP 8. Follow my notes...
#Review ALL lines for potential comments - these are important to read for value updates for paths or tag values. Do not ignore them or results may not be what you expected. 
#Begin

#Step 1: Basic variables
#$location = "usdodeast" #Update this to the location


#Step 2: Log into Azure
Connect-AzAccount -environment azureusgovernment


#Step 3: Select the correct subscription
Get-AzSubscription -SubscriptionName $"Subscription Name" | Select-AzSubscription


#Step 4: Register the PolicyInsights provider
Register-AzResourceProvider -ProviderNamespace 'Microsoft.PolicyInsights'

#Step 5: Create (2) policy definition. Can add more for more Tags if desired....


#Step 5a: Create a new policy definition #1

$defParams = @{
    Name = "AppendCommandTagToVirtualMachinesV2"
    DisplayName = "Append Command Tag to Virtual Machines V2"
    Description = "Add Command tag to a VM"
    Metadata = '{"category":"Tags"}'
    Parameter = "/Users/peter/Downloads/AZ-500 Exercise files/Configure-Security-Policies-main/m1/append_tag_parameters.json" # you may need to add the full path to the file. Testing showed I needed it. 
    Policy = "/Users/peter/Downloads/AZ-500 Exercise files/Configure-Security-Policies-main/m1/append_VM_tag.json" # you may need to add the path to the file. Testing showed I needed it. 
    
}

#This variable will hold policy #1 def parameters
$definition = New-AzPolicyDefinition @defParams 


#Step 5b: Create a new policy definition #2

$defParams = @{
    Name = "AppendSecurityOwnerTagToVirtualMachinesv2"
    DisplayName = "Append Security Owner Tag to Virtual Machines V2"
    Description = "Add security owner tag to a VM"
    Metadata = '{"category":"Tags"}'
    Parameter = "/Users/peter/Downloads/AZ-500 Exercise files/Configure-Security-Policies-main/m1/append_tag_parameters.json" # you may need to add the full path to the file. Testing showed I needed it. 
    Policy = "/Users/peter/Downloads/AZ-500 Exercise files/Configure-Security-Policies-main/m1/append_VM_tag.json" # you may need to add the path to the file. Testing showed I needed it. 
}
#this variable will hold policy #1 def parameters
$definition2 = New-AzPolicyDefinition @defParams 

#Step 5c: Create a new policy definition #3

$defParams = @{
    Name = "AppendSecurityOwnerTagToVirtualMachinesv2"
    DisplayName = "Append Environment Tag to Virtual Machines V2"
    Description = "Add Environment tag to a VM"
    Metadata = '{"category":"Tags"}'
    Parameter = "/Users/peter/Downloads/AZ-500 Exercise files/Configure-Security-Policies-main/m1/append_tag_parameters.json" # you may need to add the full path to the file. Testing showed I needed it. 
    Policy = "/Users/peter/Downloads/AZ-500 Exercise files/Configure-Security-Policies-main/m1/append_VM_tag.json" # you may need to add the path to the file. Testing showed I needed it. 
}
#this variable will hold policy #1 def parameters
$definition3 = New-AzPolicyDefinition @defParams 



#Step 6: Create an initiative to hold the policy definitions above and apply the values for the tags

$PolicyDefinition = @"
[
    {
        "policyDefinitionId": "$($definition.ResourceId)",
        "parameters": {
            "tagName": {
                "value": "USN Command"
            },
            "tagValue": {
                "value": "[parameters('USNTagCode')]"
            }
        }
    },
    {
     "policyDefinitionId": "$($definition2.ResourceId)",
        "parameters": {
            "tagName": {
                "value": "Security Owner"
            },
            "tagValue": {
                "value": "[parameters('SecurityOwner')]"
            }
        }
    },
    {
     "policyDefinitionId": "$($definition3.ResourceId)",
        "parameters": {
            "tagName": {
                "value": "Environment"
            },
            "tagValue": {
                "value": "[parameters('Environment')]"
            }
        }
    }
]
"@

$initiativeParams = @{
    Name = "AppendTagsToVirtualMachinesv2"
    DisplayName = "Append Tags Set for VMs V2"
    Description = "Append Tags to VMs"
    Metadata = '{"category":"Tags"}'
    Parameter = '{"USNTagCode": { "type": "string" }, "SecurityOwner": { "type": "string" }, "Environment": { "type": "string" }}'
    PolicyDefinition = $PolicyDefinition
}

$initiative = New-AzPolicySetDefinition @initiativeParams

#At this point you should now see 3 new custom policies in the portal with a Category of "tags"
#Now we will setup the params to assign to a scope. Notice I comment out Notscope. Uncomment that if needed and supply the variable holding the resourceid. You will have some work to do there...

#Step 7: Assign the initiave to the subscription, excluding the resource group

#PLEASE READ NOTES IN PARAMETERS BELOW

$assignParams = @{
    Name = "SecTagsVirtualMachinesv2"
    DisplayName = "Security Tags for Virtual Machines V2"
    Scope = "/subscriptions/$((Get-AzContext).Subscription.Id)" #Before running this step 7, SCOPE NEEDS TO BE MODIFIED IF YOU WANT TO USE IT AT MGMT GROUP LEVEL
    #NotScope = $rg1.ResourceId
    PolicyParameterObject = @{
        'USNTagCode'='USN_31A_EXT_Foo+bar_ABC_123_11111002303' #Before running this step 7, change this value 'USN_XYZ_ABC_123' to reflect correct value for the tag
        'SecurityOwner'='Rick Grimes - Sheriff' #Before running this step 7, change this value 'Peter Gill' to reflect correct value for the tag
        'Environment'='Eastern PA' #Before running this step 7, change this value to reflect correct value for the tag
        }
    PolicySetDefinition = $initiative
}

New-AzPolicyAssignment @assignParams

#Step 8: Expedite the scan by running the cmdlet below. Will still take up to 15 min. Check the portal under Policy/Assignments
#NOTE - WHEN YOU RUN CMDLET BELOW - CURSOR WILL NOT BE AVAILABLE AGAIN UNTIL THE SCAN COMPLETES. GO TO PORTAL AND LOOK AROUND, GRAB A COFFEE...JUST WAIT IT OUT..15 MIN is more than enough time...
Start-AzPolicyComplianceScan

#after scan completes - any VMs before this script was run will show non-compliant. Check portal for policy compliance. You will see "Not Started" until the scan completes
#We need to discuss if we want to add a remediation option.  That requires a managed identity (preferably system type) account....
#test the initiative by creating a new VM and after it completes building, look at the tag names and values to confirm. 

#End
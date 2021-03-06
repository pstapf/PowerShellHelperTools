﻿<#
	.Synopsis
	Compare the CLIXML output files of PowerShell cmdlets 

	.Description
	Compares the PowerShell cmdlet output stored in reference and difference CLIXML file
		
	.Example
	PSOutputCompare.ps1 -ReferenceCLIXMLFile <reference.xml> -DifferenceCLIXMLFile <difference.xml> -ObjectIdentifierName ObjectId -NameAttribute DisplayName
	Compares both files and identify objects by the ObjectIdentifierName attribute while showing DisplayName in the output object
    The command output's an PSCustomObject
	
	.Parameter ReferenceCLIXMLFile
	Name of an PS cmdlet output file created with export-clixml (Original data)
	
	.Parameter DifferenceCLIXMLFile
	Name of an PS cmdlet output file created with export-clixml (Current data)
	
	.Parameter ObjectIdentifierName
	Name of the property (attribute) used to identify and match objects in reference and difference file
    Cannot be the same attribute as Property NameAttribute

	.Parameter NameAttribute
	Name ot the property (attribute) used for the output custom object "Name" property
    Cannot be the same attribute as Property ObjectIdentifier
	
	.Notes
	NAME:  PSOutputCompare
	AUTHOR: Peter Stapf, ExpertCircle GmbH
	LASTEDIT: 08/16/2018
	VERSION: 0.9

	#Requires -Version 2.0
#>
param($ReferenceCLIXMLFile,$DifferenceCLIXMLFile,$objectIdentifierName,$NameAttribute)

# Load Reference and Diff XML files
$MasterConfig = Import-Clixml -Path $ReferenceCLIXMLFile
$CurrentConfig = Import-Clixml -Path $DifferenceCLIXMLFile

# Initialize empty output array
$objList = @()

# Compare reference and difference file and check for added or removed objects
$MasterObjects = $MasterConfig | Select-Object $objectIdentifierName,$NameAttribute
$CurrentObjects = $CurrentConfig | Select-Object $objectIdentifierName,$NameAttribute
$objectResultList = Compare-Object -ReferenceObject $MasterObjects -DifferenceObject $CurrentObjects -Property $objectIdentifierName

# Go to the list of added or removed objects
If ($null -ne $objectResultList)
{
    foreach ($objectResult in $objectResultList)
    {
        # Create output custom object
        $obj = New-Object -Type PSCustomObject
        $obj | Add-Member -Type NoteProperty -Name "Name" -Value $objectResult.$objectIdentifierName
        $obj | Add-Member -Type NoteProperty -Name "Property" -Value $null

        If ($objectResult.SideIndicator -eq "<=")
            { $obj | Add-Member -Type NoteProperty -Name "ChangeType" -Value "ObjectRemove" }
        
        If ($objectResult.SideIndicator -eq "=>")
            { $obj | Add-Member -Type NoteProperty -Name "ChangeType" -Value "ObjectAdd" }

        $obj | Add-Member -Type NoteProperty -Name "OldValue" -Value $null
        $obj | Add-Member -Type NoteProperty -Name "NewValue" -Value $null
        $objList += $obj      
    }
}

# Go to the list of all changes of already present objects
Foreach ($config in $MasterConfig)
{
    # Get the list off all properties (incl. NoteProperties) and on a single object for object compare
    $PropertyList = ($config | Get-Member | Where-Object { $_.MemberType -eq "Property" }).Name
    $PropertyList += ($config | Get-Member | Where-Object { $_.MemberType -eq "NoteProperty" }).Name
    $DiffObject = $CurrentConfig | Where-Object { $_.$objectIdentifierName.ToString() -eq $config.$objectIdentifierName.ToString() }

    # Compare objects the exists in reference and difference file and show changes
    If ($null -ne $DiffObject)
    {
        Foreach ($property in $PropertyList)
        {
            if ($null -ne $property)
            {
                # Convert properties with NULL value to string(NULL) to make it usable with compare-object.
                if ($null -eq $config.$property) { $config.$property = "NULL" }
                if ($null -eq $DiffObject.$property) { $DiffObject.$property = "NULL" }

                $result = Compare-Object -ReferenceObject $config.$property.ToString() -DifferenceObject $DiffObject.$property.ToString()

                if ($null -ne $result)
                {
                    # Create the output custom object with object changes
                    $oldvalue = ($result | Where-Object { $_.SideIndicator -eq "<=" }).InputObject
                    $newValue = ($result | Where-Object { $_.SideIndicator -eq "=>" }).InputObject

                    $obj = New-Object -Type PSCustomObject
                    $obj | Add-Member -Type NoteProperty -Name "Name" -Value $config.$NameAttribute
                    $obj | Add-Member -Type NoteProperty -Name "Property" -Value $property
                    if ($oldvalue -eq "NULL") { $changeType = "ValueAdd" }
                    if ($newvalue -eq "NULL") { $changeType = "ValueRemove" }
                    if ($oldvalue -ne "NULL" -and $newValue -ne "NULL") { $changeType = "ValueModify" }
                    $obj | Add-Member -Type NoteProperty -Name "ChangeType" -Value $changeType
                    $obj | Add-Member -Type NoteProperty -Name "OldValue" -Value $oldvalue
                    $obj | Add-Member -Type NoteProperty -Name "NewValue" -Value $newValue
                    $objList += $obj      
                }
            }
        }
    }
}

# Output array with all custom objects
$objList
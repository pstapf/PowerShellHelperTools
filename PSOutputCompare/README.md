# PowerShell Output Compare (Config Checker)
A PowerShell script that compares saved CLIXML output of an PowerShell command and shows all changes.

<b>Usage: PSOutputCompare.ps1 -ReferenceCLIXMLFile {master.xml} -DifferenceCLIXMLFile {current.xml} -ObjectIdentifier {AttributeName} -NameAttribute {AttributeName}</b><br/>

Sample output of an compare of Get-ADFSRelyingPartyTrust saved before and after some changes:
![GitHub Logo](./PSOutputCompare.png)

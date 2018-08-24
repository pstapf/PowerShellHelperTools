# PowerShell Output Compare (Config Checker)
A PowerShell script that compares saved CLIXML output of an PowerShell command and shows all changes.

<b>Usage: PSOutputCompare.ps1 -ReferenceCLIXMLFile {master.xml} -DifferenceCLIXMLFile {current.xml} -ObjectIdentifier {AttributeName} -NameAttribute {AttributeName}</b><br/>

Sample output of an compare of Get-ADFSRelyingPartyTrust saved before and after some changes:<br/>
![GitHub Logo](./PSOutputCompare.png)

Saved CliXML output of a cmdlet can contain an object or an object collection.<br/>
First step all added or removed objects are shown in the output.<br/>
Output column **ChangeType** will have the following values:<br/>
* ObjectAdd
* ObjectRemove
<br/>
Second step all changed properties of an still existing objects are show.<br/>
Output column **ChangeType** will have the following values:<br/>
* ValueAdd
* ValueRemove
* ValueModify

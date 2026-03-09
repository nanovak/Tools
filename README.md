# Tools

Parking lot for scripts and things

## BypassDNS

This is a PowerShell script that identifies the network adapter in use and sets it's DNS servers from DHCP to 4.2.2.2 and 4.2.2.1 to bypass ad blocking from NextDNS built into our home network infrastructure.

Usage:
`.\BypassDNS.ps1 -Mode SetStatic [-AllUp]`
`.\BypassDNS.ps1 -Mode SetDhcp [-AllUp]`


## IPAddressMailer

This is a customized version of Robert Cain's tool that checks regularly to see if you public IP has changed and sends an email if it has.
I've added support for IPv6 and changed the service used to check your machine's public IP.

## RepoSyncJob

This is a Windows batch file method to regularly update GIT repos on your local machine. The intent is to set this up as a recurring scheduled task.
## BypassDNS

This is a PowerShell script that identifies the network adapter in use and sets it's DNS servers from DHCP to 4.2.2.2 and 4.2.2.1 to bypass ad blocking from NextDNS built into our home network infrastructure.

You'll likely need to run `Set-ExecutionPolicy bypass` one time on your computer to allow local scripts to be executed.

Usage:

`.\BypassDNS.ps1 -Mode SetStatic [-AllUp]`
`.\BypassDNS.ps1 -Mode SetDhcp [-AllUp]`
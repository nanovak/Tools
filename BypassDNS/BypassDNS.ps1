[CmdletBinding()]
param(
    [ValidateSet("SetStatic","SetDhcp")]
    [string]$Mode = "SetStatic",

    # Default DNS servers requested
    [string[]]$DnsServers = @("4.2.2.2","4.2.2.1"),

    # Apply to all non-VPN adapters that are Up (physical Wi-Fi/Ethernet)
    [switch]$AllUp,

    # Strong default exclusions for VPN/virtual/tunnel adapters (customizable)
    [string]$ExcludeDescriptionRegex = "VPN|Virtual|Hyper-V|TAP|TUN|Tunnel|Loopback|WAN Miniport|WireGuard|OpenVPN|Cisco|AnyConnect|GlobalProtect|Zscaler|Fortinet|Pulse|SonicWall|Juniper"
)

function Assert-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        throw "This script must be run from an elevated PowerShell session (Run as Administrator)."
    }
}

function Get-CandidateAdapters {
    # Prefer physical adapters only; exclude VPN/virtual by description.
    # NdisPhysicalMedium values are most helpful when present; HardwareInterface helps too.
    Get-NetAdapter -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Status -eq "Up" -and
            $_.HardwareInterface -eq $true -and
            $_.InterfaceDescription -notmatch $ExcludeDescriptionRegex
        }
}

function Get-PrimaryActiveAdapter {
    $candidates = @(Get-CandidateAdapters)

    if (-not $candidates -or $candidates.Count -eq 0) {
        return $null
    }

    $candidateIfIndexes = $candidates.ifIndex

    # 1) Best: default route, but only if it's on a candidate (non-VPN physical adapter)
    $bestRoute = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue |
        Where-Object { $candidateIfIndexes -contains $_.ifIndex } |
        Sort-Object -Property RouteMetric, ifIndex |
        Select-Object -First 1

    if ($bestRoute) {
        return $candidates | Where-Object { $_.ifIndex -eq $bestRoute.ifIndex } | Select-Object -First 1
    }

    # 2) Next: any candidate with an IPv4 default gateway
    $gwIfIndex = Get-NetIPConfiguration -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPv4DefaultGateway -and
            ($candidateIfIndexes -contains $_.InterfaceIndex)
        } |
        Select-Object -First 1 -ExpandProperty InterfaceIndex

    if ($gwIfIndex) {
        return $candidates | Where-Object { $_.ifIndex -eq $gwIfIndex } | Select-Object -First 1
    }

    # 3) Fallback: lowest interface metric among candidates
    return $candidates |
        Sort-Object -Property InterfaceMetric, ifIndex |
        Select-Object -First 1
}

Assert-Admin

# Decide which adapters to target
$targets = @()

if ($AllUp) {
    $targets = @(Get-CandidateAdapters | Sort-Object -Property Name)
    if (-not $targets -or $targets.Count -eq 0) {
        throw "No eligible (non-VPN) active adapters found to configure."
    }
}
else {
    $primary = Get-PrimaryActiveAdapter
    if (-not $primary) {
        throw "No eligible (non-VPN) active adapter found to configure."
    }
    $targets = @($primary)
}

foreach ($adapter in $targets) {
    if ($Mode -eq "SetStatic") {
        Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $DnsServers
        Write-Host "Set static DNS on '$($adapter.Name)' (ifIndex $($adapter.ifIndex)) to: $($DnsServers -join ', ')" -ForegroundColor Green
    }
    else {
        Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ResetServerAddresses
        Write-Host "Reset DNS on '$($adapter.Name)' (ifIndex $($adapter.ifIndex)) back to DHCP/automatic" -ForegroundColor Yellow
    }
}

# Show resulting DNS config for the targeted adapters
Write-Host "`nCurrent DNS server addresses (IPv4) for targeted adapter(s):" -ForegroundColor Cyan
foreach ($adapter in $targets) {
    Get-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 |
        Select-Object InterfaceAlias, ServerAddresses |
        Format-List
}
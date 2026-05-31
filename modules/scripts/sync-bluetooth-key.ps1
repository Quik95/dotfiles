#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Sync a Bluetooth link key from the running Linux system to the other
    dual-boot system (NixOS <-> CachyOS), so both share a single bond.

.DESCRIPTION
    Both systems share the same physical Bluetooth adapter (same MAC), so a
    device only ever remembers ONE link key for it. After re-pairing the
    earbuds on whichever system you are booted into, run this script: it reads
    the fresh link key from the live /var/lib/bluetooth and writes the exact
    same bond into the OTHER system's /var/lib/bluetooth.

    The result: both systems present an identical key, so the earbuds connect
    without re-pairing on either side.

    This script does NOT mount anything. You mount the other system's root
    yourself and pass its mount point via -TargetRoot. It works unchanged from
    either NixOS or CachyOS - the running system is always the source, the
    mounted one is always the target.

        # example: mount CachyOS (btrfs) read-write, then sync
        sudo mount -o subvol=/ /dev/nvme0n1p6 /mnt/other
        sudo pwsh ./sync-bluetooth-key.ps1 -TargetRoot /mnt/other

    Requires root to read/write the (root-owned, 0600) BlueZ key files; it
    re-execs itself via sudo when needed.

.PARAMETER TargetRoot
    Mount point of the OTHER system's root filesystem - the directory that
    contains 'var/lib/bluetooth'. If you mounted the btrfs top-level (subvol=/)
    instead of the '@' subvolume, point at either the mount or its '@' child;
    the script appends '@' automatically when needed.

.PARAMETER DeviceMac
    Bluetooth MAC of the earbuds. Defaults to the Redmi Buds 5.

.PARAMETER AdapterMac
    Bluetooth adapter MAC (identical on both systems, same hardware).

.PARAMETER WhatIf
    Preview: show the current target key vs. the new one without writing.

.EXAMPLE
    sudo pwsh ./sync-bluetooth-key.ps1 -TargetRoot /mnt/other
    Copy the freshly paired key to the system mounted at /mnt/other.

.EXAMPLE
    pwsh ./sync-bluetooth-key.ps1 -TargetRoot /mnt/other -WhatIf
    Show what would change without writing.

.EXAMPLE
    sudo pwsh ./sync-bluetooth-key.ps1 -TargetRoot /mnt/other -DeviceMac AA:BB:CC:DD:EE:FF
    Sync a different paired device instead of the Redmi Buds 5.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [string]$TargetRoot,

    [Parameter()]
    [ValidatePattern('^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$')]
    [string]$DeviceMac = '9C:49:52:E8:4C:8E',

    [Parameter()]
    [ValidatePattern('^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$')]
    [string]$AdapterMac = 'F4:28:9D:36:1A:7C'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step { param([string]$m) Write-Host ">> $m" -ForegroundColor Cyan }
function Write-Ok   { param([string]$m) Write-Host "   $m" -ForegroundColor Green }
function Die        { param([string]$m) Write-Error $m; exit 1 }

function Get-LinkKey {
    # Returns the Key= value from a BlueZ 'info' file, or $null.
    param([string]$InfoPath)
    if (-not (Test-Path -LiteralPath $InfoPath)) { return $null }
    $line = Select-String -LiteralPath $InfoPath -Pattern '^Key=' -List
    if (-not $line) { return $null }
    return ($line.Line -replace '^Key=', '').Trim()
}

# --- Elevate if not root (BlueZ key files are root-owned, mode 0600) --------
if ([int](id -u) -ne 0) {
    Write-Step 'Not root - re-executing with sudo...'
    $forward = @()
    foreach ($kv in $PSBoundParameters.GetEnumerator()) {
        if ($kv.Value -is [switch] -or $kv.Value -is [bool]) {
            if ($kv.Value) { $forward += "-$($kv.Key)" }
        }
        else {
            $forward += "-$($kv.Key)"; $forward += "$($kv.Value)"
        }
    }
    & sudo pwsh -NoProfile -File $PSCommandPath @forward
    exit $LASTEXITCODE
}

# --- Resolve the target's bluetooth directory ------------------------------
if (-not (Test-Path -LiteralPath $TargetRoot -PathType Container)) {
    Die "TargetRoot '$TargetRoot' does not exist or is not a directory. Mount the other system there first."
}

# Accept either the '@' subvolume mount or a top-level (subvol=/) mount.
$btBase = Join-Path $TargetRoot 'var/lib/bluetooth'
if (-not (Test-Path -LiteralPath $btBase)) {
    $btBaseAt = Join-Path $TargetRoot '@/var/lib/bluetooth'
    if (Test-Path -LiteralPath $btBaseAt) {
        $btBase = $btBaseAt
        Write-Ok "Using '@' subvolume under the mount point."
    }
    else {
        Die "No 'var/lib/bluetooth' under '$TargetRoot' (also tried '@/var/lib/bluetooth'). Is this the right mount point?"
    }
}

# Guard against pointing at the live system by mistake.
if ((Resolve-Path -LiteralPath $btBase).Path -eq '/var/lib/bluetooth') {
    Die "TargetRoot resolves to the LIVE /var/lib/bluetooth. Point it at the OTHER (mounted) system."
}

# --- Read the fresh key from the live (source) system ----------------------
$btRel   = "$AdapterMac/$DeviceMac"
$srcInfo = "/var/lib/bluetooth/$btRel/info"
$srcKey  = Get-LinkKey $srcInfo
if (-not $srcKey) {
    Die "No link key for $DeviceMac on the running system ($srcInfo). Pair the device HERE first."
}
Write-Step "Source (live) key: $srcKey"

# --- Compare with the target -----------------------------------------------
$dstDir  = Join-Path $btBase $btRel
$dstInfo = Join-Path $dstDir 'info'
$dstKey  = Get-LinkKey $dstInfo
Write-Step "Target ($btBase) key (before): $(if ($dstKey) { $dstKey } else { '<none>' })"

if ($dstKey -eq $srcKey) {
    Write-Ok 'Keys already match - nothing to do.'
    return
}

# --- Write an identical bond into the target -------------------------------
if ($PSCmdlet.ShouldProcess($dstInfo, "Write link key $srcKey")) {
    # Back up any existing bond on the target.
    if (Test-Path -LiteralPath $dstInfo) {
        $bak = "$dstInfo.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -LiteralPath $dstInfo -Destination $bak -Force
        Write-Ok "Backed up old target info -> $(Split-Path -Leaf $bak)"
    }

    # Copy info (+ attributes) verbatim so the bond is byte-identical.
    New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
    Copy-Item -LiteralPath $srcInfo -Destination $dstInfo -Force
    $srcAttr = "/var/lib/bluetooth/$btRel/attributes"
    if (Test-Path -LiteralPath $srcAttr) {
        Copy-Item -LiteralPath $srcAttr -Destination (Join-Path $dstDir 'attributes') -Force
    }

    # Copy the SDP/name cache entry too, so the device resolves cleanly.
    $srcCache = "/var/lib/bluetooth/$AdapterMac/cache/$DeviceMac"
    if (Test-Path -LiteralPath $srcCache) {
        $dstCacheDir = Join-Path $btBase "$AdapterMac/cache"
        New-Item -ItemType Directory -Force -Path $dstCacheDir | Out-Null
        Copy-Item -LiteralPath $srcCache -Destination (Join-Path $dstCacheDir $DeviceMac) -Force
        & chmod 700 $dstCacheDir
        & chmod 600 (Join-Path $dstCacheDir $DeviceMac)
    }

    # BlueZ permissions: directories 700, files 600, owned by root.
    & chown -R 'root:root' $dstDir
    & chmod 700 $dstDir
    & chmod 600 $dstInfo
    if (Test-Path -LiteralPath (Join-Path $dstDir 'attributes')) {
        & chmod 600 (Join-Path $dstDir 'attributes')
    }

    & sync
    $verify = Get-LinkKey $dstInfo
    if ($verify -ne $srcKey) {
        Die "Verification failed: target key is '$verify', expected '$srcKey'."
    }
    Write-Ok "Target key (after):  $verify"
    Write-Host ""
    Write-Host "Done. Both systems now share key $srcKey." -ForegroundColor Green
    Write-Host "Unmount the target, reboot into it, and the device connects without re-pairing." -ForegroundColor Green
}

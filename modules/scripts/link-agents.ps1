<#
.SYNOPSIS
    Creates symbolic links (CLAUDE.md, GEMINI.md) pointing to AGENTS.md files.

.DESCRIPTION
    Recursively searches for AGENTS.md files and creates symbolic links named
    CLAUDE.md and GEMINI.md in the same directory, pointing to AGENTS.md.
    Uses relative paths so links remain valid if the directory is moved.

.PARAMETER DryRun
    Preview mode - shows what would be done without making changes.

.PARAMETER Force
    Overwrite existing CLAUDE.md/GEMINI.md files. Default behavior is to skip.

.PARAMETER Path
    Starting directory for recursive search. Defaults to current directory.

.EXAMPLE
    link-coding-agents-context
    Creates symlinks starting from current directory.

.EXAMPLE
    link-coding-agents-context -DryRun
    Preview what would be created without making changes.

.EXAMPLE
    link-coding-agents-context -Force -Path /home/user/projects
    Create symlinks, overwriting existing files, starting from specified path.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [Alias('h', '?')]
    [switch]$Help,

    [Parameter()]
    [Alias('n')]
    [switch]$DryRun,

    [Parameter()]
    [Alias('f')]
    [switch]$Force,

    [Parameter(Position = 0)]
    [string]$Path = (Get-Location).Path
)

# Show help and exit
if ($Help) {
    $helpText = @"
link-coding-agents-context - Create CLAUDE.md and GEMINI.md symlinks to AGENTS.md

USAGE:
    link-coding-agents-context [OPTIONS] [PATH]

ARGUMENTS:
    PATH                Starting directory for recursive search (default: current directory)

OPTIONS:
    -DryRun, -n         Preview mode - show what would be done without making changes
    -Force, -f          Overwrite existing CLAUDE.md/GEMINI.md files (default: skip)
    -Help, -h, -?       Show this help message

EXAMPLES:
    link-coding-agents-context
        Create symlinks starting from current directory

    link-coding-agents-context -DryRun
        Preview what would be created without making changes

    link-coding-agents-context -Force /home/user/projects
        Create symlinks, overwriting existing files, starting from specified path

    link-coding-agents-context -n -f .
        Dry-run with force flag, starting from current directory

DESCRIPTION:
    Recursively searches for AGENTS.md files and creates symbolic links named
    CLAUDE.md and GEMINI.md in the same directory. Uses relative paths so links
    remain valid if the directory is moved.

    Existing files are skipped by default. Use -Force to overwrite them.
"@
    Write-Host $helpText
    exit 0
}

# Strict mode for better error catching
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Initialize statistics
$stats = @{
    Found   = 0
    Created = 0
    Skipped = 0
    Errors  = 0
}

# Target symlink names
$linkNames = @('CLAUDE.md', 'GEMINI.md')

# Helper function for consistent output with dry-run prefix
function Write-Status {
    param(
        [string]$Message,
        [string]$Indent = ''
    )
    
    $prefix = $DryRun ? '[DRY RUN] ' : ''
    Write-Host "${prefix}${Indent}${Message}"
}

# Validate starting directory exists
$resolvedPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
if (-not $resolvedPath) {
    Write-Error "Directory not found: $Path"
    exit 1
}

$startPath = $resolvedPath.Path
Write-Status "Scanning: $startPath"

# Find all AGENTS.md files recursively
try {
    $agentsFiles = Get-ChildItem -Path $startPath -Filter 'AGENTS.md' -Recurse -File -ErrorAction Stop
}
catch {
    Write-Error "Failed to search directory: $_"
    exit 1
}

# Process each AGENTS.md file
foreach ($agentsFile in $agentsFiles) {
    $stats.Found++
    $directory = $agentsFile.DirectoryName
    
    # Calculate relative display path from start directory
    $relativeDirDisplay = if ($directory -eq $startPath) {
        '.'
    }
    else {
        # Get relative path and normalize to forward slashes for consistent display
        $relPath = $directory.Substring($startPath.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar, '/')
        "./$($relPath -replace '\\', '/')"
    }
    
    Write-Status "Found AGENTS.md in: $relativeDirDisplay"
    
    # Create symlinks for each target name
    foreach ($linkName in $linkNames) {
        $linkPath = Join-Path -Path $directory -ChildPath $linkName
        $targetExists = Test-Path -Path $linkPath
        
        try {
            if ($targetExists) {
                if (-not $Force) {
                    # Skip existing file
                    Write-Status "Skipping $linkName (already exists)" -Indent '  '
                    $stats.Skipped++
                    continue
                }
                
                # Force mode: remove existing file/link
                if (-not $DryRun) {
                    Remove-Item -Path $linkPath -Force -ErrorAction Stop
                }
                Write-Status "Removing existing $linkName" -Indent '  '
            }
            
            # Create symbolic link with relative target
            Write-Status "Creating $linkName -> AGENTS.md" -Indent '  '
            
            if (-not $DryRun) {
                # Use relative path 'AGENTS.md' as target
                # New-Item requires us to be in the target directory for relative paths to work correctly
                Push-Location -Path $directory
                try {
                    New-Item -ItemType SymbolicLink -Path $linkName -Target 'AGENTS.md' -Force:$Force -ErrorAction Stop | Out-Null
                }
                finally {
                    Pop-Location
                }
            }
            
            $stats.Created++
        }
        catch {
            Write-Warning "  Error creating $linkName : $_"
            $stats.Errors++
        }
    }
}

# Print summary
Write-Host ''
Write-Host '=== Summary ==='
Write-Host "AGENTS.md files found: $($stats.Found)"
Write-Host "Links created: $($stats.Created)"
Write-Host "Links skipped: $($stats.Skipped)"
Write-Host "Errors: $($stats.Errors)"

# Exit with error code if there were errors
if ($stats.Errors -gt 0) {
    exit 1
}

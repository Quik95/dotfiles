if test (count $argv) -lt 1; or string match -q -- '--help' $argv[1]; or string match -q -- '-h' $argv[1]
    echo "Usage: detach [OPTIONS] COMMAND [ARGS...]"
    echo ""
    echo "Run a command as a detached systemd transient unit."
    echo "The process will survive terminal closure and session end."
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "Examples:"
    echo "  detach timer 5m        Start a 5-minute timer"
    echo "  detach webstorm        Launch WebStorm IDE detached"
    return 0
end

# Generate a unique unit name based on command and timestamp
set -l cmd_name (string replace -a ' ' '-' -- $argv[1])
set -l unit_name "detach-$cmd_name-"(date +%s)

# Collect environment variables to pass through (excluding shell-specific ones)
set -l env_args
set -l excluded_vars FISH_VERSION SHLVL _ OLDPWD PWD
for var in (set --names --export)
    if not contains $var $excluded_vars
        set -a env_args -E $var
    end
end

# Use systemd-run to create a transient user service (NOT scope)
# --user: run as user service (no root required)
# --unit: custom name for easy identification
# --description: human-readable description
# --collect: automatically clean up the unit after it exits
# --working-directory: preserve the current working directory
# Service mode runs asynchronously and returns immediately
systemd-run --user \
            --unit="$unit_name" \
            --description="Detached: $argv" \
            --collect \
            --working-directory="$PWD" \
            $env_args \
            $argv >/dev/null 2>&1

if test $status -eq 0
    echo "Detached as: $unit_name"
end

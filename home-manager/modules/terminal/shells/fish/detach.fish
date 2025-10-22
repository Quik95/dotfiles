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

# Use systemd-run to create a transient user service (NOT scope)
# --user: run as user service (no root required)
# --unit: custom name for easy identification
# --description: human-readable description
# --collect: automatically clean up the unit after it exits
# Service mode runs asynchronously and returns immediately
systemd-run --user \
            --unit="$unit_name" \
            --description="Detached: $argv" \
            --collect \
            $argv >/dev/null 2>&1

if test $status -eq 0
    echo "Detached as: $unit_name"
end

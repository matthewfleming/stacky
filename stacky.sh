# This can't be run directly - add to your .bashrc or .zshrc
# alias stacky='source /path/to/stacky.sh'
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo Stacky - An interactive pulumi stack selector that remembers the selected stack and working dir
    echo Usage: stacky [command]
    echo Available commands
    echo -e "  cd\t\t\tDon't use sticky stack - change to puluimi dir and run pulumi stack select"
    echo -e "  select\t\tSelect a stack"
    echo -e "  [pulumi command]\tRun pulumi command on the selected stack"
    echo -e "  which\t\t\tDisplay selected stack"
elif [ "$1" == "select" ] || [ "$1" == "cd" ]; then
    find . -ipath './Pulumi.*.yaml' -or -ipath '**/*infrastructure/Pulumi.*.yaml' -or -ipath '**/.pulumi/Pulumi.*.yaml' -maxdepth 3 | while read -l path
        echo "$(basename "$path" | sed -e s/Pulumi.// -e s/.yaml//) $(dirname "$path")"
    done >/tmp/stacks_options
    if [ -s /tmp/stacks_options ]; then
        dialog --erase-on-exit --keep-tite --menu 'Choose a stack' 0 0 0 --file /tmp/stacks_options 2>/tmp/stacks_selection
        if [ $? -eq 0 ] && [ -n /tmp/stacks_selection ]; then
            __name=$(cat /tmp/stacky_selection)
            __dir=$(readlink -f $(awk "/$__name / {print \$2}" < /tmp/stacky_options))
            if [ "$1" == "cd" ]; then
                cd $__dir
                pulumi stack select $__name
            else
                export PULUMI_STACK=$__name
                export PULUMI_DIR=$__dir
            fi
            unset __name __dir
            rm -f /tmp/stacks_*
            echo "Stack $PULUMI_STACK selected" >&2
        fi
    else
        echo "No stacks found" >&2
    fi
elif [ -z "$PULUMI_STACK" ]; then
    echo "No stack selected" >&2
else
    echo "Selected stack is $PULUMI_STACK" >&2
    if [ "$1" != "which" ]; then
        pulumi --cwd=$PULUMI_DIR --stack=$PULUMI_STACK $@
    fi
fi

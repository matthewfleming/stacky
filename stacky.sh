# This can't be run directly - add to your .bashrc or .zshrc
# alias stacky='source ~/path/to/stacky.sh'
if [ "$1" == "select" ]; then
    find . -ipath './Pulumi.*.yaml' -or -ipath '**/*infrastructure/Pulumi.*.yaml' -maxdepth 3 | while read path; do
        echo "$(basename "$path" | sed -e s/Pulumi.// -e s/.yaml//) $(dirname "$path")"
    done >/tmp/stacks_options
    if [ -s /tmp/stacks_options ]; then
        dialog --erase-on-exit --keep-tite --menu 'Choose a stack' 0 0 0 --file /tmp/stacks_options 2>/tmp/stacks_selection
        if [ $? -eq 0 ] && [ -n /tmp/stacks_selection ]; then
            export PULUMI_STACK=$(cat /tmp/stacks_selection)
            export PULUMI_DIR=$(awk "/$PULUMI_STACK / {print \$2}" < /tmp/stacks_options)
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

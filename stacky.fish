function stacky -d "Run pulumi with a sticky stack"
    if test "$argv[1]" = select
        find . -ipath './Pulumi.*.yaml' -or -ipath '**/*infrastructure/Pulumi.*.yaml' -maxdepth 3 | while read -l path
            set dir (dirname "$path")
            set file (basename "$path" | string sub -s 8 -e -5)
            echo "$file $dir"
        end >/tmp/stacky_options
        if [ -s /tmp/stacky_options ]
            dialog --erase-on-exit --keep-tite --menu 'Choose a stack' 0 0 0 --file /tmp/stacky_options 2>/tmp/stacky_selection
            if [ $status -eq 0 -a -n /tmp/stacky_selection ]
                set -gx PULUMI_STACK (cat /tmp/stacky_selection)
                set -gx PULUMI_DIR (realpath (awk "/$PULUMI_STACK / {print \$2}" < /tmp/stacky_options))
                rm -f /tmp/stacky_*
                echo "Stack $PULUMI_STACK selected"
            end
        else
            echo "No stacks found" >&2
            return 1
        end
    else if test -z "$argv[1]"
        echo "No stack selected" >&2
        return 2
    else
        echo "Selected stack is $PULUMI_STACK" >&2
        if test "$argv[1]" != which
            pulumi --cwd=$PULUMI_DIR --stack=$PULUMI_STACK $argv
        end
    end
end

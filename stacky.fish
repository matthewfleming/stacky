function stacky -d "Run pulumi with a sticky stack"
    if string match -qr -- "--help|-h" "$argv[1]"
        echo Stacky - An interactive pulumi stack selector that remembers the selected stack and working dir
        echo Usage: stacky [command]
        echo Available commands
        echo -e "  cd\t\t\tDon't use sticky stack - change to puluimi dir and run pulumi stack select"
        echo -e "  select\t\tSelect a stack"
        echo -e "  [pulumi command]\tRun pulumi command on the selected stack"
        echo -e "  which\t\t\tDisplay selected stack"
        return
    end
    if string match -qr "select|cd" "$argv[1]"
        find -E . -iregex '.*\/Pulumi\..*\.yaml$' -not -path '**/node_modules/*' -not -path '**/vendor/*' -maxdepth 4 | while read -l path
            set dir (dirname "$path")
            set file (basename "$path" | string sub -s 8 -e -5)
            echo "$file $dir"
        end >/tmp/stacky_options
        if [ -s /tmp/stacky_options ]
            dialog --erase-on-exit --keep-tite --menu 'Choose a stack' 0 0 0 --file /tmp/stacky_options 2>/tmp/stacky_selection
            if [ $status -eq 0 -a -n /tmp/stacky_selection ]
                set name (cat /tmp/stacky_selection)
                set dir (realpath (awk "/$name / {print \$2}" < /tmp/stacky_options))
                if test "$argv[1]" = cd
                    cd "$dir"
                    pulumi stack select "$name"
                else
                    set -gx PULUMI_STACK "$name"
                    set -gx PULUMI_DIR "$dir"
                    rm -f /tmp/stacky_*
                    echo "Stack $PULUMI_STACK selected"
                end
            end
        else
            echo "No stacks found" >&2
            return 1
        end
    else if test -z "$PULUMI_STACK"
        echo "No stack selected" >&2
        return 2
    else
        echo "Selected stack is $PULUMI_STACK" >&2
        if test "$argv[1]" != which
            pulumi --cwd=$PULUMI_DIR --stack=$PULUMI_STACK $argv
        end
    end
end

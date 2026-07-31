#! /usr/bin/env tclsh

proc main {{input -} {--indent 4} {--reverse false}} {
    set ch [expr {$input eq "-" ? "stdin" : [open $input]}]
    while {[gets $ch line] > -1} {
        if {${--reverse}} {
            regexp {^(\s*)(\S?.*)$} $line _ space line
            set line $space[string reverse $line]
        }

        puts [string repeat { } ${--indent}]$line
    }
}

source autoopts.tcl
::autoopts::go {indenter pro v1.1.0 - indents input with spaces}

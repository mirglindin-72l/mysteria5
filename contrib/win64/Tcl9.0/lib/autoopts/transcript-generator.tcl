#! /usr/bin/env tclsh
foreach command {
    {./example.tcl --help}
    {./example.tcl --wrong}
    {./example.tcl file1 file2 file3}
    {./example.tcl --indent}
    {./example.tcl ./example.tcl --indent 11}
    {./example.tcl --reverse ./example.tcl --indent 11}
} {
    puts "$ $command"
    catch {exec [info nameofexecutable] {*}$command >@ stdout 2>@ stdout}
    puts {}
}

if {0} {
    # Code for the tcl-only version
    package ifneeded argparse 0.61 [list source [file join $dir @PACKAGE_NAME@.tcl]]
} else {
    # Code for the non-tcl-only version
    if {[package vsatisfies [package provide Tcl] 9.0-]} {
        package ifneeded argparse 0.61 "[list load [file join $dir tcl9argparse061.dll]]"
    } else {
        package ifneeded argparse 0.61 "[list load [file join $dir argparse061t.dll]]"
    }
}






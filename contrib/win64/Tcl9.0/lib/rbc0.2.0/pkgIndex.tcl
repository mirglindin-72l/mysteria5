package ifneeded rbc 0.2.0 [list apply {{dir} {
    # This package always requires Tk
    package require Tk
    load [file join $dir tcl9rbc020.dll]
    source [file join $dir graph.tcl]
}} $dir]

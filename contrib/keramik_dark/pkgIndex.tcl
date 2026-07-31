if {![file isdirectory [file join $dir keramik_dark]]} { return }
if {![package vsatisfies [package provide Tcl] 8.4]} { return }

package ifneeded ttk::theme::keramik_dark 0.6.2 \
    [list source [file join $dir keramik_dark.tcl]]

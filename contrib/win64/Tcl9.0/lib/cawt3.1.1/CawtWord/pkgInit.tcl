# Copyright: 2007-2025 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

proc _InitCawtWord { dir version } {
    package provide cawtword $version

    source [file join $dir wordConst.tcl]
    source [file join $dir wordTypeLib.tcl]
    source [file join $dir wordBasic.tcl]
    source [file join $dir wordUtil.tcl]
}

# Copyright: 2007-2025 Paul Obermeier (obermeier@poSoft.de)
# Distributed under BSD license.

proc _InitCawtOutlook { dir version } {
    package provide cawtoutlook $version

    source [file join $dir outlookConst.tcl]
    source [file join $dir outlookTypeLib.tcl]
    source [file join $dir outlookColor.tcl]
    source [file join $dir outlookBasic.tcl]
    source [file join $dir outlookCalendar.tcl]
    source [file join $dir outlookCategory.tcl]
    source [file join $dir outlookContact.tcl]
    source [file join $dir outlookAccount.tcl]
    source [file join $dir outlookMail.tcl]
}

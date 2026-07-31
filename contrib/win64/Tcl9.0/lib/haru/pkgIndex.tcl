# Copyright (c) 2022-2025 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# haru - Tcl bindings for libharu (http://libharu.org/) PDF library.

package ifneeded haru 2.1 [list apply {dir {

    source [file join $dir haru.tcl]
    source [file join $dir haru_enum.tcl]
    source [file join $dir haru_struct.tcl]
    source [file join $dir haru_error.tcl]
    source [file join $dir haru_alias.tcl]
    source [file join $dir haru_utils.tcl]
    source [file join $dir haru_funcs.tcl]

}} $dir]
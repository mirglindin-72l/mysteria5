#
# Tcl package index file - generated from pkgIndex.tcl.in
#

package ifneeded xtal 2.0a1 \
    [list apply [list {dir} {
        package require platform
        set package_ns ::xtal
        set initName [string totitle xtal]
        if {[package vsatisfies [package require Tcl] 9]} {
            set fileName "tcl9xtal20a1.dll"
        } else {
            set fileName "xtal20a1t.dll"
        }
        set platformId [platform::identify]
        set searchPaths [list [file join $dir $platformId] \
                             {*}[lmap platformId [platform::patterns $platformId] {
                                 file join $dir $platformId
                             }] \
                             $dir]
        foreach path $searchPaths {
            set lib [file join $path $fileName]
            if {[file exists $lib]} {
                uplevel #0 [list load $lib $initName]
                # Load was successful
                set ${package_ns}::dll_path $lib
                set ${package_ns}::package_dir $dir
                foreach f {xtal ptast ptutil shell} {
                    uplevel #0 [list source [file join $dir $f.tcl]]
                }
                package provide xtal 2.0a1
                return
            }
        }
        error "Could not locate $fileName in directories [join $searchPaths {, }]"
    }] $dir]

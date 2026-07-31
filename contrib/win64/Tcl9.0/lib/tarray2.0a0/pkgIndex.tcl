#
# Tcl package index file - generated from pkgIndex.tcl.in
#

package ifneeded tarray 2.0a0 \
    [list apply [list {dir} {
        package require platform
        set package_ns ::tarray
        set initName [string totitle tarray]
        if {[package vsatisfies [package require Tcl] 9]} {
            set fileName "tcl9tarray20a0.dll"
        } else {
            set fileName "tarray20a0t.dll"
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
                source [file join $dir tarray.tcl]
                return
            }
        }
        error "Could not locate $fileName in directories [join $searchPaths {, }]"
    }] $dir]

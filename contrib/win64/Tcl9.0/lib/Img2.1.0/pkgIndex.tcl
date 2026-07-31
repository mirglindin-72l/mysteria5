# -*- tcl -*- Tcl package index file
# --- --- --- Handcrafted, final generation by configure.

if {[package vsatisfies [package provide Tcl] 9.0-]} {
    package ifneeded tkimg 2.1.0 [list load [file join $dir tcl9tkimg210.dll]]
} else {
    package ifneeded tkimg 2.1.0 [list load [file join $dir tkimg210t.dll]]
}
# Compatibility hack. When asking for the old name of the package
# then load all format handlers and base libraries provided by tkImg.
# Actually we ask only for the format handlers, the required base
# packages will be loaded automatically through the usual package
# mechanism.

# When reading images without specifying it's format (option -format),
# the available formats are tried in reversed order as listed here.
# Therefore file formats with some "magic" identifier, which can be
# recognized safely, should be added at the end of this list.

package ifneeded Img 2.1.0 {
    package require img::window
    package require img::tga
    package require img::ico
    package require img::pcx
    package require img::sgi
    package require img::sun
    package require img::xbm
    package require img::xpm
    package require img::jpeg
    package require img::png
    package require img::tiff
    package require img::bmp
    package require img::ppm
    package require img::pixmap
    package provide Img 2.1.0
}

package ifneeded img::bmp 2.1.0 [list load [file join $dir tcl9tkimgbmp210.dll]] 
package ifneeded img::dted 2.1.0 [list load [file join $dir tcl9tkimgdted210.dll]] 
package ifneeded img::flir 2.1.0 [list load [file join $dir tcl9tkimgflir210.dll]] 
package ifneeded img::gif 2.1.0 [list load [file join $dir tcl9tkimggif210.dll]] 
package ifneeded img::ico 2.1.0 [list load [file join $dir tcl9tkimgico210.dll]] 
if {[package vsatisfies [package provide Tcl] 9.0]} { 
package ifneeded jpegtcl 9.6.0 [list load [file join $dir tcl9jpegtcl960.dll]] 
} else { 
package ifneeded jpegtcl 9.6.0 [list load [file join $dir jpegtcl960t.dll]] 
} 
package ifneeded img::jpeg 2.1.0 [list load [file join $dir tcl9tkimgjpeg210.dll]] 
if {[package vsatisfies [package provide Tcl] 9.0]} { 
package ifneeded zlibtcl 1.3.1 [list load [file join $dir tcl9zlibtcl131.dll]] 
} else { 
package ifneeded zlibtcl 1.3.1 [list load [file join $dir zlibtcl131t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0]} { 
package ifneeded pngtcl 1.6.48 [list load [file join $dir tcl9pngtcl1648.dll]] 
} else { 
package ifneeded pngtcl 1.6.48 [list load [file join $dir pngtcl1648t.dll]] 
} 
if {[package vsatisfies [package provide Tcl] 9.0]} { 
package ifneeded tifftcl 4.7.0 [list load [file join $dir tcl9tifftcl470.dll]] 
} else { 
package ifneeded tifftcl 4.7.0 [list load [file join $dir tifftcl470t.dll]] 
} 
package ifneeded img::pcx 2.1.0 [list load [file join $dir tcl9tkimgpcx210.dll]] 
package ifneeded img::pixmap 2.1.0 [list load [file join $dir tcl9tkimgpixmap210.dll]] 
package ifneeded img::png 2.1.0 [list load [file join $dir tcl9tkimgpng210.dll]] 
package ifneeded img::ppm 2.1.0 [list load [file join $dir tcl9tkimgppm210.dll]] 
package ifneeded img::ps 2.1.0 [list load [file join $dir tcl9tkimgps210.dll]] 
package ifneeded img::raw 2.1.0 [list load [file join $dir tcl9tkimgraw210.dll]] 
package ifneeded img::sgi 2.1.0 [list load [file join $dir tcl9tkimgsgi210.dll]] 
package ifneeded img::sun 2.1.0 [list load [file join $dir tcl9tkimgsun210.dll]] 
package ifneeded img::tga 2.1.0 [list load [file join $dir tcl9tkimgtga210.dll]] 
package ifneeded img::tiff 2.1.0 [list load [file join $dir tcl9tkimgtiff210.dll]] 
package ifneeded img::window 2.1.0 [list load [file join $dir tcl9tkimgwindow210.dll]] 
package ifneeded img::xbm 2.1.0 [list load [file join $dir tcl9tkimgxbm210.dll]] 
package ifneeded img::xpm 2.1.0 [list load [file join $dir tcl9tkimgxpm210.dll]] 

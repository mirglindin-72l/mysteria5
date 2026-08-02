if { $::tcl_platform(os) == {Darwin} } {
	set winc [glob /opt/homebrew/Cellar/mingw-w64/*/bin/x86_64-w64-mingw32-gcc]
} elseif { $::tcl_platform(os) != {Windows NT} } {
	set winc x86_64-w64-mingw32-gcc-posix
} else {
	set winc {C:\mingw64\bin\gcc}
}

### I need to compile:
###
### MacOS to MacOS -> working
### MacOS/Linux to Windows -> need to rework conditions here
### Windows to Windows -> untested
### Linux to Linux -> untested, should work
###

set targets {win}

foreach target $targets {

set dir [file join . lib]
catch { file mkdir $dir }
set td [glob [file join $dir *.o]]
foreach f $td {
	catch { file delete $f }
}

set cmn {-DUSE_THREAD_ALLOC=1 -D_REENTRANT=1 -D_THREAD_SAFE=1 -DHAVE_PTHREAD_ATTR_SETSTACKSIZE=1 -DHAVE_READDIR_R=1 -DTCL_THREADS=1 -DUSE_TCL_STUBS}
set lcmn {}
set audio {}

if { $target == {mac} } {
	lappend audio -framework CoreAudio -framework AudioToolbox -framework AudioUnit -framework CoreFoundation -framework CoreServices
	set pcpath [glob /opt/homebrew/Cellar/*/*/lib/pkgconfig]
	set env(PKG_CONFIG_PATH) [join $pcpath {:}]
	set cl [exec pkg-config --libs tcl]
	set cc [exec pkg-config --cflags tcl]
	set ext ".dylib"
	set c [list gcc -c -fPIC -DNDEBUG]
	set l [list gcc -dynamiclib ]
} elseif { $target != {win} } {
	set cl [exec pkg-config --libs tcl]
	set cc [exec pkg-config --cflags tcl]
	set ext ".so"
	set c [list gcc -c -fPIC -DNDEBUG]
	set l [list gcc -shared]
} else {
	set cc {-I./contrib/win64/Tcl9.0/include -static-libgcc -static-libstdc++}
	set cl {-L./contrib/tcl9.0.4/win -ltclstub}
	set ext ".dll"
	set c [list $winc -c -fPIC -DNDEBUG]
	set l [list $winc -shared]
}

puts "build_wrappers for target $target:"
puts "cl:"
puts "$cl"
puts "cc:"
puts "$cc"
puts "ext:"
puts "$ext"
puts "c:"
puts "$c"
puts "l:"
puts "$l"

if { $target == {mac} } {
	set pcl [exec pkg-config --libs libsodium]
	set pcc [exec pkg-config --cflags libsodium]
} elseif { $target != {win} } {
	set pcl [exec pkg-config --libs libsodium]
	set pcc [exec pkg-config --cflags libsodium]
} else {
	set pcc {-I./contrib/win64/include -static-libgcc -static-libstdc++}
	set pcl {-L./contrib/win64 -llibsodium-26}
}

puts "start cc sodium_wrapper"
catch {
exec {*}$c -Wall -Os -c -I./ {*}$pcc {*}$cmn {*}$cc ./contrib/sodium_wrapper.c -o ./lib/sodium_wrapper.o
} res
puts "end cc sodium_wrapper $res"
puts "start ld sodium_wrapper"
catch {
set la {}
lappend la {*}$l ./lib/sodium_wrapper.o -Os -L./ -L./lib {*}$pcl {*}$lcmn {*}$cl -o ./lib/sodium_wrapper${ext}
puts $la
exec {*}$la
} res
puts "end ld sodium_wrapper $res"

if { $target == {mac} } {
	set pcl [exec pkg-config --libs portaudio-2.0] 
	set pcc [exec pkg-config --cflags portaudio-2.0] 
} elseif { $target != {win} } {
	set pcl [exec pkg-config --libs portaudio-2.0] 
	set pcc [exec pkg-config --cflags portaudio-2.0] 
} else {
	set pcl {-L./contrib/win64 -lportaudio_x64}
	set pcc {-I./contrib/win64/include -I./contrib/pa -static-libgcc -static-libstdc++}
}

puts "start cc portaudio_wrapper"
catch {
exec {*}$c -Wall -Os -c -I./ {*}$pcc {*}$cmn {*}$cc ./contrib/portaudio_wrapper.c -o ./lib/portaudio_wrapper.o
} res
puts "end cc portaudio_wrapper $res"
puts "start ld portaudio_wrapper"
catch {
set la {}
lappend la {*}$l ./lib/portaudio_wrapper.o -Os -L./ -L./lib {*}$pcl {*}$lcmn {*}$audio {*}$cl -o ./lib/portaudio_wrapper${ext}
puts $la
exec {*}$la
} res
puts "end ld portaudio_wrapper $res"

if { $target == {mac} } {
	set pcl [exec pkg-config --libs opus]
	set pcc [exec pkg-config --cflags opus]
} elseif { $target != {win} } {
	set pcl [exec pkg-config --libs opus]
	set pcc [exec pkg-config --cflags opus]
} else {
	set pcl {-L./contrib/win64 -lopus}
	set pcc {-I./contrib/win64/include -Wno-error=incompatible-pointer-types -Os -c -static-libgcc -static-libstdc++}
}

puts "start cc opus_wrapper"
catch {
exec {*}$c -Wall -Os -c -I./ {*}$pcc {*}$cmn {*}$cc ./contrib/opus_wrapper.c -o ./lib/opus_wrapper.o
} res
puts "end cc opus_wrapper $res"
puts "start ld opus_wrapper"
catch {
set la {}
lappend la {*}$l ./lib/opus_wrapper.o -Os -L./ -L./lib {*}$pcl {*}$lcmn {*}$audio {*}$cl -o ./lib/opus_wrapper${ext}
puts $la
exec {*}$la
} res
puts "end ld opus_wrapper $res"

set dir [file join . lib]
set td [glob [file join $dir *.o]]
foreach f $td {
	catch { file delete $f }
}


}

# mysteria5

A P2P messenger, mostly written in TCL scripting language with some C (critcl) wrappers
for outside libraries.

i2pd, tcl/tk, libsodium, portaudio, libopus are used, of other things.

it also includes a copy of ttkthemes, package from I don't remember there. Keramik theme and
a dark mode improvisation on it are used from that.

to run, use ./mysteria for MacOS (and Linux, but not checked to work lately) and mysteria.bat for Windows.

the package.sh script can be used to package only necessary things.

since it uses critcl, aforementioned libraries have to be installed for it to work under
MacOS or Linux. an I2P router has to be running with SAM enabled.

## using it

you need to add some other peers by I2P destinations. extended mode of the main window
("+" button) allows to copy our destination (has to be done when I2P session is in "ready"
state) or paste someone else's.

then one can create and add groups, or add contacts. contacts can be either similarly
copied/pasted, or search via DHT in directory, same with groups.

there's mail, chat, versioned documents and almost nonexistent voice calls.

there's rudimentary file exchange (functional enough to be used for exchanging files)
and PNG images support (for letters or chat messages with inline display).

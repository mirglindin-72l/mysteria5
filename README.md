# mysteria5

A P2P messenger, mostly written in TCL scripting language with some C (initially critcl, now shlibs) wrappers
for outside libraries.

i2pd, tcl/tk, libsodium, portaudio, libopus are used, of other things.

it also includes a copy of ttkthemes, package from I don't remember there. Keramik theme and
a dark mode improvisation on it are used from that.

to run, use ./mysteria for MacOS (and Linux, but not checked to work lately) and mysteria.bat for Windows.

the package.sh script can be used to package only necessary things.

aforementioned libraries have to be installed for it to work under
MacOS or Linux. an I2P router has to be running with SAM enabled.

for Windows, dll blobs of used libraries from the repo can be replaced with ones locally built,
but that's not described here.

## using it

you need to add some other peers by I2P destinations. extended mode of the main window
("+" button) allows to copy our destination (has to be done when I2P session is in "ready"
state) or paste someone else's.

then one can create and add groups, or add contacts. contacts can be either similarly
copied/pasted, or searched via DHT in directory, same with groups.

group requests and contact requests windows are intended for accepting requests to write to us directly
or to join our group initially. (don't remember if the latter still works or was completely replaced with
control rules)

there's mail, chat, versioned documents and almost nonexistent voice calls.

there's rudimentary file exchange (functional enough to be used for exchanging files)
and PNG images support (for letters or chat messages with inline display).

the update ("@") button refers to announcing ourselves on the DHT (not needed generally),
the gather button - to requesting group and contact sync with peers.

group details ("?" button) can be used to, if we are group owner, post control rules.
control rules define membership and who can write to group.

versioned documents are in a very basic stage.

## on quality

this is a very personal project, terribly clumsy and emotionally important.
there's plenty of unused code, bad code, commented out and left in place code, duplicate code
and code clearly outrageous for anyone who worked as a programmer. sorry.

## building

run `tclsh build_wrappers.tcl` ; to package some sort of ready Windows version, run `package.sh`

## mea culpa

to fix Windows linking errors, Claude advice has been used ; so this project is no more AI-free ;
it is however entirely vibe-coded in the sense that vibe is what was guiding me on project decisions more
than any specific clear goal or hope.

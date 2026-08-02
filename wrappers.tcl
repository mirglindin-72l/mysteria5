log_puts "ALL" "load wrappers"
switch $tcl_platform(platform) {
	windows {
		log_puts "ALL" "load sodium_wrapper"
		load [file join [pwd] lib sodium_wrapper.dll]
		log_puts "ALL" "load sodium_wrapper done"
		log_puts "ALL" "load portaudio_wrapper"
		load [file join [pwd] lib portaudio_wrapper.dll]
		log_puts "ALL" "load portaudio_wrapper done"
		log_puts "ALL" "load opus_wrapper"
		load [file join [pwd] lib opus_wrapper.dll]
		log_puts "ALL" "load opus_wrapper done"
	}
	unix {
		log_puts "ALL" "load sodium_wrapper"
		load [file join [pwd] lib sodium_wrapper[info sharedlibextension]]
		log_puts "ALL" "load sodium_wrapper done"
		log_puts "ALL" "load portaudio_wrapper"
		load [file join [pwd] lib portaudio_wrapper[info sharedlibextension]]
		log_puts "ALL" "load portaudio_wrapper done"
		log_puts "ALL" "load opus_wrapper"
		load [file join [pwd] lib opus_wrapper[info sharedlibextension]]
		log_puts "ALL" "load opus_wrapper done"
	}
}

::sodium::init

log_puts "ALL" "load wrappers done"

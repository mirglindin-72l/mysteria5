proc msg_set {} {
	::msgcat::mcload msg
	set locales [::msgcat::mcloadedlocales loaded]
	if { [lsearch -all -inline $locales $::options(locale)] == {} } {
		set ::options(locale) en
	}
	::msgcat::mclocale $::options(locale)
}

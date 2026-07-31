proc crypto_cksum args {
	#log_puts "ALL" "crypto_cksum $args"
	set h [lsearch -all -inline $args "-hex"]
	set args [lsearch -all -inline -not $args "-hex"]
	#set ret [::sha1::sha1 {*}$args]
	set ret [::sodium::hash {*}$args]
	return [binary encode hex $ret]
}

# full -> enc_priv/sig_priv/enc_pub/sig_pub 
proc crypto_gen {len} {
	#log_puts "ALL" "crypto_gen $len"
	set pair_enc [::sodium::genpair_enc]
	set pair_sig [::sodium::genpair_sig]
	set enc_pub [lindex $pair_enc 0]
	set enc_priv [lindex $pair_enc 1]
	set sig_pub [lindex $pair_sig 0]
	set sig_priv [lindex $pair_sig 1]
	#return [::pki::rsa::generate $len]
	return [wrap "[wrap $enc_priv] [wrap $sig_priv] [wrap $enc_pub] [wrap $sig_pub]"]
}

proc crypto_parse_pub {s} {
	#log_puts "ALL" "crypto_parse_pub $s"
	set l [split [unwrap $s] " "]
	if { [llength $l] != 2 } {
		return
	}
	#return [::pki::pkcs::parse_public_key $s] 
	return $s
}

proc crypto_parse_priv {s} {
	#log_puts "ALL" "crypto_parse_priv $s"
	set l [split [unwrap $s] " "]
	if { [llength $l] != 4 } {
		return
	}
	#return [::pki::pkcs::parse_key $s] 
	return $s
}

# pub -> enc_pub/sig_pub
proc crypto_exp_pub {s} {
	#log_puts "ALL" "crypto_exp_pub $s"
	set l [split [unwrap $s] " "]
	if { [llength $l] != 4 } {
		return
	}
	#return [::pki::public_key $key]
	return [wrap "[lindex $l 2] [lindex $l 3]"]
}

proc crypto_exp_priv {s} {
	#log_puts "ALL" "crypto_exp_priv $s"
	set l [split [unwrap $s] " "]
	if { [llength $l] != 4 } {
		return
	}
	#return [::pki::key $s] 
	return $s
}

proc crypto_sig {data privkey} {
	set l [split [unwrap $privkey] " "]
	#log_puts "ALL" "crypto_sig key list $l"
	set k [unwrap [lindex $l 1]]
	if { $k == {} } {
		return
	}
	#return [::pki::sign $data $privkey]
	return [::sodium::sig $k $data]
}

proc crypto_ver {s data pubkey} {
	set l [split [unwrap $pubkey] " "]
	#log_puts "ALL" "crypto_ver key list $l"
	set k [unwrap [lindex $l 1]]
	if { $k == {} } {
		return "false"
	}
	#return [::pki::verify $s $data $pubkey]
	set ret [::sodium::ver $k $data $s]
	if { $ret != 0 } {
		return "false"
	} else {
		return "true"
	}
}

proc crypto_dec args {
	set h [lsearch -all -inline $args "-hex"]
	set args [lsearch -all -inline -not $args "-hex"]
	set args [lsearch -all -inline -not $args "-pub"]
	set args [lsearch -all -inline -not $args "-priv"]
	set data [lindex $args 0]
	set key [lindex $args 1]
	set l [split [unwrap $key] " "]
	#log_puts "ALL" "crypto_dec key list $l"
	set k [unwrap [lindex $l 0]]
	set p [unwrap [lindex $l 2]]
	if { $k == {} || $p == {} } {
		log_puts "ERR" "crypto_dec k or p is empty" 
		return
	}
	if { $h != {} } {
		#set data [binary decode hex $data]
		#set ret [::pki::decrypt -hex -priv $data $key]
	} else {
		#set ret [::pki::decrypt -priv $data $key]
	}
	set ret [::sodium::dec $k $p $data]
	return $ret
}

proc crypto_enc args {
	set h [lsearch -all -inline $args "-hex"]
	set args [lsearch -all -inline -not $args "-hex"]
	set args [lsearch -all -inline -not $args "-pub"]
	set args [lsearch -all -inline -not $args "-priv"]
	set data [lindex $args 0]
	set key [lindex $args 1]
	set l [split [unwrap $key] " "]
	#log_puts "ALL" "crypto_enc key list $l"
	set k [unwrap [lindex $l 0]]
	set ret [::sodium::enc $k $data]
	if { $h != {} } {
		#set ret [binary encode hex $ret]
		#set ret [::pki::encrypt -hex -pub $data $key]
	} else {
		#set ret [::pki::encrypt -pub $data $key]
	}
	return $ret
}

proc crypto_symgen {} {
	return [::sodium::symgen]
	#return [read $::random(chan) 32]
}

proc crypto_symenc {data key init} {
	return [::sodium::symenc $key $data]
	#return [::tinyaes::enc $data $key $init] 
}

proc crypto_symdec {data key init} {
	return [::sodium::symdec $key $data]
	#return [::tinyaes::dec $data $key $init] 
}

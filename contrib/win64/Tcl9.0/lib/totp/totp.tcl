# -----------------------------------------------------------------------------
# TOTP Library v0.1 - RFC 6238 Implementation
# Time-based One-Time Password Algorithm for Tcl
# Compatible with Google Authenticator, Microsoft Authenticator, etc.
# -----------------------------------------------------------------------------

package require sha1
package require base32

namespace eval ::totp {
    variable version 0.1


    # -----------------------------------------------------------------------------
    # totp::generate_secret - Generate a random Base32 secret key
    # Arguments:
    #   length - Length of the secret (default: 16, recommended: 16 or 32)
    # Returns:
    #   Base32 encoded secret string
    # -----------------------------------------------------------------------------
    proc generate_secret {{length 16}} {
        set chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        set secret ""
        for {set i 0} {$i < $length} {incr i} {
            set index [expr {int(rand() * 32)}]
            append secret [string index $chars $index]
        }
        return $secret
    }

    # -----------------------------------------------------------------------------
    # totp::generate_code - Generate TOTP code from binary key and counter
    # Arguments:
    #   key     - Binary key (decoded from Base32)
    #   counter - Time counter (usually clock seconds / 30)
    #   digits  - Number of digits in OTP (default: 6)
    # Returns:
    #   Zero-padded OTP string
    # -----------------------------------------------------------------------------
    proc generate_code {key counter {digits 6}} {
        # Convert counter to 8-byte binary (64-bit big-endian)
        set msg [binary format W $counter]
        
        # HMAC-SHA1
        set hash [sha1::hmac -bin -key $key $msg]
        
        # Dynamic truncation per RFC 4226
        binary scan [string index $hash end] c last_byte
        set offset [expr {$last_byte & 0x0F}]
        
        binary scan [string range $hash $offset [expr {$offset + 3}]] I raw_bits
        set code [expr {$raw_bits & 0x7FFFFFFF}]
        
        set otp [expr {$code % (10 ** $digits)}]
        return [format %0${digits}d $otp]
    }

    # -----------------------------------------------------------------------------
    # totp::validate - Validate a TOTP code against a Base32 secret
    # Arguments:
    #   secret_base32 - Base32 encoded secret
    #   input_code    - User-provided OTP code
    #   window        - Time window tolerance (default: 1 = ±30 seconds)
    # Returns:
    #   1 if valid, 0 if invalid
    # -----------------------------------------------------------------------------
    proc validate {secret_base32 input_code {window 1}} {
        # Decode Base32 secret to binary key
        set key [::base32::decode $secret_base32]
        
        # Get current time step (30-second blocks)
        set time_step [expr {[clock seconds] / 30}]
        
        # Check current code and window (tolerance for clock drift)
        for {set offset [expr {-$window}]} {$offset <= $window} {incr offset} {
            set expected [::totp::generate_code $key [expr {$time_step + $offset}]]
            if {$input_code eq $expected} {
                return 1
            }
        }
        
        return 0
    }

    # -----------------------------------------------------------------------------
    # totp::get_current_code - Get current TOTP code for a secret
    # Arguments:
    #   secret_base32 - Base32 encoded secret
    # Returns:
    #   Current 6-digit OTP code
    # -----------------------------------------------------------------------------
    proc get_current_code {secret_base32} {
        set key [::base32::decode $secret_base32]
        set time_step [expr {[clock seconds] / 30}]
        return [::totp::generate_code $key $time_step]
    }

    # -----------------------------------------------------------------------------
    # totp::get_uri - Generate otpauth:// URI for QR code generation
    # Arguments:
    #   secret  - Base32 encoded secret
    #   account - User account/email
    #   issuer  - Service name
    # Returns:
    #   otpauth:// URI string
    # -----------------------------------------------------------------------------
    proc get_uri {secret account issuer} {
        return "otpauth://totp/${issuer}:${account}?secret=${secret}&issuer=${issuer}"
    }

    # -----------------------------------------------------------------------------
    # totp::time_remaining - Seconds remaining before code expires
    # Returns:
    #   Seconds (0-29)
    # -----------------------------------------------------------------------------
    proc time_remaining {} {
        return [expr {30 - ([clock seconds] % 30)}]
    }
}

package provide totp 0.1

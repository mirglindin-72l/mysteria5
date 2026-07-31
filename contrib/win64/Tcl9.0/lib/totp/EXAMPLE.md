# Tcl TOTP Library v0.1

A simple Tcl library for generating and validating Time-based One-Time Passwords (TOTP) according to **RFC 6238**. It is compatible with Google Authenticator, Microsoft Authenticator, Authy, and other common authenticator apps.

This library provides all the necessary functions to:
- Generate a new random Base32 secret.
- Create an `otpauth://` URI for QR code generation.
- Validate a user-provided TOTP code with a time-drift window.
- Get the current valid code for debugging or display.

## Quick Start

### 1. Loading the Library

Place the `totp0.1` directory in your project's `libs` folder and ensure it's added to Tcl's `auto_path`. Then, load the package:

```tcl
package require totp
```

### 2. Generating a Secret and QR Code URI

To set up a new user, you need to generate a secret and provide it to them, usually via a QR code.

```tcl
# 1. Define user and service names
set account "user@example.com"
set issuer "My Awesome App"

# 2. Generate a new random 16-character Base32 secret
set secret [::totp::generate_secret]
# => RZBEFJX75KTFWYMU (example output)

# 3. Create the otpauth:// URI for the QR code
set uri [::totp::get_uri $secret $account $issuer]
# => otpauth://totp/My%20Awesome%20App:user@example.com?secret=RZBEFJX75KTFWYMU&issuer=My%20Awesome%20App

# You can now use this URI with a QR code generation tool.
# For example, using the 'qrencode' command-line tool:
# exec qrencode -o qr.png $uri
```

### 3. Validating a User's Code

When the user logs in, they will provide a 6-digit code from their authenticator app. Use `::totp::validate` to check if it's correct.

The validation function automatically handles clock drift by checking the current time step, the previous one, and the next one (`t-1`, `t`, `t+1`).

```tcl
# The secret you stored for the user during setup
set user_secret "RZBEFJX75KTFWYMU"

# The code submitted by the user
set user_code "123456"

if {[::totp::validate $user_secret $user_code]} {
    puts "✅ Code is valid!"
} else {
    puts "❌ Code is invalid."
}
```

## API Reference

All procedures are within the `::totp` namespace.

---

`::totp::generate_secret {?length 16?}`
- Generates a random, cryptographically insecure Base32-encoded secret key.
- **length**: The desired length of the key (default is 16, which is standard).
- **Returns**: A Base32 string.

---

`::totp::get_uri {secret account issuer}`
- Creates a standard `otpauth://` URI.
- **secret**: The Base32 secret key.
- **account**: The user's identifier (e.g., email or username).
- **issuer**: The name of your service or application.
- **Returns**: A formatted URI string.

---

`::totp::validate {secret_base32 input_code {?window 1?}}`
- Validates a user-provided code against the secret.
- **secret_base32**: The user's Base32 secret.
- **input_code**: The 6-digit code from the user.
- **window**: The tolerance for time drift in 30-second steps. A window of `1` (default) checks the previous, current, and next time steps.
- **Returns**: `1` if the code is valid, `0` otherwise.

---

`::totp::get_current_code {secret_base32}`
- Gets the current valid TOTP code for a secret. Useful for debugging.
- **secret_base32**: The user's Base32 secret.
- **Returns**: The current 6-digit code as a string.

```tcl
set current_code [::totp::get_current_code "RZBEFJX75KTFWYMU"]
puts "The current code is: $current_code"
```

---

`::totp::time_remaining`
- Calculates how many seconds are left before the current code expires.
- **Returns**: An integer from 0 to 29.

```tcl
set seconds_left [::totp::time_remaining]
puts "Code expires in $seconds_left seconds."
```

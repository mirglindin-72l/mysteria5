# TOTP for Tcl

A lightweight Tcl library implementing Time-based One-Time Password (TOTP) algorithm according to **RFC 6238**. Compatible with Google Authenticator, Microsoft Authenticator, Authy, and other standard authenticator applications.

## Features

- ✅ RFC 6238 compliant TOTP implementation
- ✅ Generate cryptographic secrets for new users
- ✅ Create `otpauth://` URIs for QR code generation
- ✅ Validate TOTP codes with configurable time-drift tolerance
- ✅ Zero external dependencies (uses Tcl's built-in `sha1` and `base32` packages)
- ✅ Simple, clean API

## Installation

1. Copy the `totp0.1` directory to your Tcl library path
2. Add it to your `auto_path` if needed
3. Load the package:

```tcl
package require totp
```

## Quick Start

### Generate a Secret for New User

```tcl
package require totp

# Generate a random Base32 secret
set secret [::totp::generate_secret]
# => "JBSWY3DPEHPK3PXP" (example)

# Create otpauth:// URI for QR code
set uri [::totp::get_uri $secret "user@example.com" "MyApp"]
# => "otpauth://totp/MyApp:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=MyApp"

# Display QR code to user (using external tool)
exec qrencode -o qr.png $uri
```

### Validate User's Code

```tcl
# User enters 6-digit code from their authenticator app
set user_code "123456"
set stored_secret "JBSWY3DPEHPK3PXP"

if {[::totp::validate $stored_secret $user_code]} {
    puts "Authentication successful"
} else {
    puts "Invalid code"
}
```

## API Reference

### `::totp::generate_secret ?length?`

Generates a random Base32-encoded secret key.

- **length** (optional): Length of the secret (default: 16)
- **Returns**: Base32 string

```tcl
set secret [::totp::generate_secret]
set longer_secret [::totp::generate_secret 32]
```

### `::totp::get_uri secret account issuer`

Creates a standard `otpauth://` URI for QR code generation.

- **secret**: Base32 secret key
- **account**: User identifier (email, username, etc.)
- **issuer**: Your application/service name
- **Returns**: URI string

```tcl
set uri [::totp::get_uri $secret "alice@example.com" "MyService"]
```

### `::totp::validate secret_base32 input_code ?window?`

Validates a TOTP code against the secret.

- **secret_base32**: Base32 secret key
- **input_code**: 6-digit code from user
- **window** (optional): Time-drift tolerance in 30-second steps (default: 1)
- **Returns**: 1 if valid, 0 if invalid

```tcl
if {[::totp::validate $secret "123456"]} {
    # Code is valid
}

# Check with larger time window (±60 seconds)
if {[::totp::validate $secret "123456" 2]} {
    # Code is valid within ±60 seconds
}
```

### `::totp::get_current_code secret_base32`

Gets the current valid TOTP code. Useful for testing and debugging.

- **secret_base32**: Base32 secret key
- **Returns**: Current 6-digit code

```tcl
set current_code [::totp::get_current_code $secret]
puts "Current code: $current_code"
```

### `::totp::time_remaining`

Returns seconds remaining before the current code expires.

- **Returns**: Integer from 0 to 29

```tcl
set seconds [::totp::time_remaining]
puts "Code expires in $seconds seconds"
```

## Dependencies

- `sha1` package (standard with Tcl)
- `base32` package (standard with Tcl)

## Example Usage

See [EXAMPLE.md](EXAMPLE.md) for detailed usage examples and integration patterns.

## Security Considerations

- Store secrets securely (encrypted database, secure storage)
- Use HTTPS when transmitting secrets or QR codes
- Implement rate limiting on validation attempts
- Consider requiring TOTP only for sensitive operations
- The `generate_secret` function uses `rand()` which is not cryptographically secure; consider using `/dev/urandom` or similar for production

## License

MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Version

Current version: 0.1

## 🙏 Acknowledgements

Created to support lightweight interprocess communication in modular Tcl projects.

## ☕ Support my work

If this project has been helpful to you or saved you some development time, consider buying me a coffee! Your support helps me keep exploring new optimizations and sharing quality code.

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/rauleli)

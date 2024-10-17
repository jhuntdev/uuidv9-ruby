# UUID v9

## Fast, lightweight, zero-dependency Ruby implementation of UUID version 9

The v9 UUID supports both sequential (time-based) and non-sequential (random) UUIDs with an optional prefix of up to four bytes, an optional checksum, and sufficient randomness to avoid collisions. It uses the UNIX timestamp for sequential UUIDs and CRC-8 for checksums. A version digit can be added if desired, but is omitted by default.

To learn more about UUID v9, please visit the website: https://uuidv9.jhunt.dev

## Installation

Install UUID v9 from Rubygems

```bash
gem install uuid-v9
```

## Usage

```ruby
require 'uuid-v9'

ordered_id = UUIDv9::UUIDv9.generate
prefixed_ordered_id = UUIDv9::UUIDv9.generate(prefix: 'a1b2c3d4')
unordered_id = UUIDv9::UUIDv9.generate(timestamp: false)
prefixed_unordered_id = UUIDv9::UUIDv9.generate(prefix: 'a1b2c3d4', timestamp: false)
ordered_id_with_checksum = UUIDv9::UUIDv9.generate(checksum: true)
ordered_id_with_version = UUIDv9::UUIDv9.generate(version: true)
ordered_id_with_legacy_mode = UUIDv9::UUIDv9.generate(legacy: true)

is_valid = UUIDv9::UUIDv9.valid?(ordered_id)
is_valid_with_checksum = UUIDv9::UUIDv9.valid?(ordered_id_with_checksum, checksum: true)
is_valid_with_version = UUIDv9::UUIDv9.valid?(ordered_id_with_version, version: true)
```

## Backward Compatibility

Some UUID validators check for specific features of v1 or v4 UUIDs. This causes some valid v9 UUIDs to appear invalid. Three possible workarounds are:

1) Use the built-in validator (recommended)
2) Use legacy mode*
3) Bypass the validator (not recommended)

_*Legacy mode adds version and variant digits to immitate v1 or v4 UUIDs depending on the presence of a timestamp._

## License

This project is licensed under the [MIT License](LICENSE).
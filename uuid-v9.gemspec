# frozen_string_literal: true

Gem::Specification.new do |spec|
    spec.name          = "uuid-v9"
    spec.version       = "0.1.0"
    spec.authors       = ["JHunt"]
    spec.email         = ["hello@jhunt.dev"]
    spec.summary       = %q{"Fast, lightweight, zero-dependency Ruby implementation of UUID version 9"}
    spec.description   = %q{"The v9 UUID supports both sequential (time-based) and non-sequential (random) UUIDs with an optional prefix of up to four bytes, an optional checksum, and sufficient randomness to avoid collisions. It uses the UNIX timestamp for sequential UUIDs and CRC-8 for checksums. A version digit can be added if desired, but is omitted by default."}
    spec.homepage      = "https://uuidv9.jhunt.dev"
    spec.license       = "MIT"
  
    spec.files         = Dir["{lib,spec}/**/*", "README.md", "LICENSE"]
    spec.require_paths = ["lib"]
end
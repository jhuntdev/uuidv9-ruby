class UUIDv9
  UUID_REGEX = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/
  BASE16_REGEX = /^[0-9a-fA-F]+$/

  def self.calc_checksum(hex_string)
    data = hex_string.scan(/.{1,2}/).map { |byte| byte.to_i(16) }
    polynomial = 0x07
    crc = 0x00
  
    data.each do |byte|
      crc ^= byte
      8.times do
        if crc & 0x80 != 0
          crc = (crc << 1) ^ polynomial
        else
          crc <<= 1
        end
      end
    end
  
    crc &= 0xFF
    crc.to_s(16).rjust(2, '0')
  end

  def self.verify_checksum(uuid)
    base16_string = uuid.delete('-')[0, 30]
    crc = calc_checksum(base16_string)
    crc == uuid[34, 2]
  end

  def self.check_version(uuid, version = nil)
    version_digit = uuid[14]
    variant_digit = uuid[19]
    (!version || version_digit == version) &&
      (version_digit == '9' || (['1', '4'].include?(version_digit) && "89abAB".include?(variant_digit)))
  end

  def self.is_uuid?(uuid)
    !uuid.empty? && UUID_REGEX.match?(uuid)
  end

  def self.is_valid_uuidv9?(uuid, options)
    is_uuid?(uuid) &&
      (!options.key?(:checksum) || !options[:checksum] || verify_checksum(uuid)) &&
      (!options.key?(:version) || !options[:version] || check_version(uuid))
  end

  def self.random_bytes(count)
    Array.new(count) { rand(0..15).to_s(16) }.join
  end

  def self.random_char(chars)
    chars[rand(chars.length)]
  end

  def self.is_base16?(str)
    BASE16_REGEX.match?(str)
  end

  def self.validate_prefix(prefix)
    raise ArgumentError, 'Prefix must be a string' if prefix.nil?
    raise ArgumentError, 'Prefix must be no more than 8 characters' if prefix.length > 8
    raise ArgumentError, 'Prefix must be only hexadecimal characters' unless is_base16?(prefix)
  end

  def self.add_dashes(str)
    "#{str[0, 8]}-#{str[8, 4]}-#{str[12, 4]}-#{str[16, 4]}-#{str[20..]}"
  end

  def self.generate(options = {})
    prefix = options.fetch(:prefix, nil).to_s
    timestamp = options.fetch(:timestamp, true)
    checksum = options.fetch(:checksum, false)
    version = options.fetch(:version, false)
    legacy = options.fetch(:legacy, false)

    if prefix && !prefix.empty?
      validate_prefix(prefix)
      prefix = prefix.downcase
    end

    center = case timestamp
            when true
              Time.now.to_i.to_s(16)
            when Time
              timestamp.to_i.to_s(16)
            when Numeric, String
              Time.at(timestamp.to_i).to_i.to_s(16)
            else
              ''
            end

    suffix_length = 32 - prefix.length - center.length - (checksum ? 2 : 0) - (legacy ? 2 : (version ? 1 : 0))
    suffix = random_bytes(suffix_length)

    joined = "#{prefix}#{center}#{suffix}"

    if legacy
      joined = "#{joined[0, 12]}#{center.length > 0 ? '1' : '4'}#{joined[12, 3]}#{random_char('89ab')}#{joined[15..]}"
    elsif version
      joined = "#{joined[0, 12]}9#{joined[12..]}"
    end

    joined += calc_checksum(joined) if checksum

    add_dashes(joined)
  end
end
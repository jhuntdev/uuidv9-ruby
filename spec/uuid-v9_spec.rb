require 'rspec/autorun'
require_relative '../lib/uuid-v9'

UUID_REGEX = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/
UUID_V1_REGEX = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-1[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$/
UUID_V4_REGEX = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$/
UUID_V9_REGEX = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-9[0-9a-fA-F]{3}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/

describe 'UUIDv9' do
  it 'should validate as a UUID' do
    id1 = UUIDv9.generate()
    id2 = UUIDv9.generate({ prefix: 'a1b2c3d4' })
    id3 = UUIDv9.generate({ prefix: 'a1b2c3d4', timestamp: false })
    id4 = UUIDv9.generate({ prefix: 'a1b2c3d4', checksum: true })
    id5 = UUIDv9.generate({ prefix: 'a1b2c3d4', checksum: true, version: true })
    id6 = UUIDv9.generate({ prefix: 'a1b2c3d4', checksum: true, legacy: true })

    expect(UUID_REGEX.match?(id1)).to be true
    expect(UUID_REGEX.match?(id2)).to be true
    expect(UUID_REGEX.match?(id3)).to be true
    expect(UUID_REGEX.match?(id4)).to be true
    expect(UUID_REGEX.match?(id5)).to be true
    expect(UUID_REGEX.match?(id6)).to be true
  end

  it 'should generate sequential UUIDs' do
    id1 = UUIDv9.generate()
    sleep(1)
    id2 = UUIDv9.generate()
    sleep(1)
    id3 = UUIDv9.generate()

    expect(id1 < id2).to be true
    expect(id2 < id3).to be true
  end

  it 'should generate sequential UUIDs with a prefix' do
    id1 = UUIDv9.generate({ prefix: 'a1b2c3d4' })
    sleep(1)
    id2 = UUIDv9.generate({ prefix: 'a1b2c3d4' })
    sleep(1)
    id3 = UUIDv9.generate({ prefix: 'a1b2c3d4' })

    expect(id1 < id2).to be true
    expect(id2 < id3).to be true
    expect(id1[0, 8]).to eq 'a1b2c3d4'
    expect(id2[0, 8]).to eq 'a1b2c3d4'
    expect(id3[0, 8]).to eq 'a1b2c3d4'
    expect(id1[9, 8]).to eq id2[9, 8]
    expect(id2[9, 8]).to eq id3[9, 8]
  end

  it 'should generate non-sequential UUIDs' do
    id_s = UUIDv9.generate({ timestamp: false })
    sleep(1)
    id_ns = UUIDv9.generate({ timestamp: false })

    expect(id_s[0, 4]).not_to eq id_ns[0, 4]
  end

  it 'should generate non-sequential UUIDs with a prefix' do
    id_s = UUIDv9.generate({ prefix: 'a1b2c3d4', timestamp: false })
    sleep(1)
    id_ns = UUIDv9.generate({ prefix: 'a1b2c3d4', timestamp: false })

    expect(id_s[0, 8]).to eq 'a1b2c3d4'
    expect(id_ns[0, 8]).to eq 'a1b2c3d4'
    expect(id_s[9, 8]).not_to eq id_ns[9, 8]
  end

  it 'should generate UUIDs with a checksum' do
    id1 = UUIDv9.generate({ checksum: true })
    id2 = UUIDv9.generate({ timestamp: false, checksum: true })

    expect(UUID_REGEX.match?(id1)).to be true
    expect(UUID_REGEX.match?(id2)).to be true
    expect(UUIDv9.verify_checksum(id1)).to be true
    expect(UUIDv9.verify_checksum(id2)).to be true
  end

  it 'should generate UUIDs with a version' do
    id1 = UUIDv9.generate({ version: true })
    id2 = UUIDv9.generate({ timestamp: false, version: true })

    expect(UUID_REGEX.match?(id1)).to be true
    expect(UUID_REGEX.match?(id2)).to be true
    expect(UUID_V9_REGEX.match?(id1)).to be true
    expect(UUID_V9_REGEX.match?(id2)).to be true
  end

  it 'should generate backward compatible UUIDs' do
    id1 = UUIDv9.generate({ checksum: true, legacy: true })
    id2 = UUIDv9.generate({ prefix: 'a1b2c3d4', legacy: true })
    id3 = UUIDv9.generate({ timestamp: false, legacy: true })
    id4 = UUIDv9.generate({ prefix: 'a1b2c3d4', timestamp: false, legacy: true })

    expect(UUID_REGEX.match?(id1)).to be true
    expect(UUID_REGEX.match?(id2)).to be true
    expect(UUID_REGEX.match?(id3)).to be true
    expect(UUID_REGEX.match?(id4)).to be true
    expect(UUID_V1_REGEX.match?(id1)).to be true
    expect(UUID_V1_REGEX.match?(id2)).to be true
    expect(UUID_V4_REGEX.match?(id3)).to be true
    expect(UUID_V4_REGEX.match?(id4)).to be true
  end

  it 'should correctly validate and verify checksum' do
    id1 = UUIDv9.generate({ checksum: true })
    id2 = UUIDv9.generate({ timestamp: false, checksum: true })
    id3 = UUIDv9.generate({ prefix: 'a1b2c3d4', checksum: true })
    id4 = UUIDv9.generate({ prefix: 'a1b2c3d4', timestamp: false, checksum: true })
    id5 = UUIDv9.generate({ checksum: true, version: true })
    id6 = UUIDv9.generate({ checksum: true, legacy: true })
    id7 = UUIDv9.generate({ timestamp: false, checksum: true, legacy: true })

    expect(UUIDv9.is_uuid?(id1)).to be true
    expect(UUIDv9.is_uuid?('not-a-real-uuid')).to be false
    expect(UUIDv9.is_valid_uuidv9?(id1, { checksum: true })).to be true
    expect(UUIDv9.is_valid_uuidv9?(id2, { checksum: true })).to be true
    expect(UUIDv9.is_valid_uuidv9?(id3, { checksum: true })).to be true
    expect(UUIDv9.is_valid_uuidv9?(id4, { checksum: true })).to be true
    expect(UUIDv9.is_valid_uuidv9?(id5, { checksum: true, version: true })).to be true
    expect(UUIDv9.is_valid_uuidv9?(id6, { checksum: true, version: true })).to be true
    expect(UUIDv9.is_valid_uuidv9?(id7, { checksum: true, version: true })).to be true
    expect(UUIDv9.verify_checksum(id1)).to be true
    expect(UUIDv9.verify_checksum(id2)).to be true
    expect(UUIDv9.verify_checksum(id3)).to be true
    expect(UUIDv9.verify_checksum(id4)).to be true
    expect(UUIDv9.verify_checksum(id5)).to be true
    expect(UUIDv9.verify_checksum(id6)).to be true
    expect(UUIDv9.verify_checksum(id7)).to be true
  end
end

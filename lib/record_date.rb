# Copied from hathitrust_catalog_indexer/lib/ht_traject/ht_macros.rb

module RecordDate
  # Some dates we're not going to bother with
  BAD_DATE_TYPES = {
    'n' => true,
    # 'u' => true,
    'b' => true
  }.freeze

  CONTAINS_FOUR_DIGITS = /(\d{4})/.freeze

  # Get a date from a record, as best you can
  # Try to get it from the 008; if not, the 260
  def self.get_raw_date(r)
    get_008_date(r) or get_260_date(r)
  end

  def self.get_date(r)
    raw = get_raw_date(r)
    convert_raw_date(raw)
  end

  def self.convert_raw_date(d)
    return nil unless d

    d.gsub(/u/, '0')
  end

  def self.bad_date_type?(ohoh8)
    BAD_DATE_TYPES.has_key? ohoh8[6]
  end

  def self.get_008_date(r)
    return nil unless r['008'] && (r['008'].value.size > 10)

    ohoh8 = r['008'].value

    return nil if bad_date_type?(ohoh8)

    date = ohoh8[7..10].downcase
    return nil if (date == '0000') || date =~ /\|/
    return nil unless date =~ /\A\d[\du]{3}/

    date
  end

  def self.get_260_date(r)
    return nil unless r['260'] && r['260']['c']

    m = CONTAINS_FOUR_DIGITS.match(r['260']['c'])
    m && m[1]
  end
end

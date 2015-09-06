class Fixnum
  def is_numeric?
    true
  end
end

class String
  def is_numeric?
    Float self rescue false
  end

  def pretty_url
    mb_chars.normalize(:kd)
      .gsub(/[^\x00-\x7F]/n, '')
      .gsub(/[^a-z_0-9 -]/i, '')
      .gsub(/ +/, '_')
      .downcase.to_s
  end
end

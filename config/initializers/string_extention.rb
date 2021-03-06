module StringExtention
  def to_utf8
    # Iconv.iconv("iso-8859-1", "utf-8", self).to_s
    # Ruby 2 is already UTF8
    self
  end

  def cut(chars_qt)
    string = ""
    chars_qt.times do |c|
      string << self[c].chr unless self[c].nil?
    end
    string << "..." if chars_qt < self.size
    return string
  end

  def to_default_date
    Date.parse(self)
  rescue
    'invalid date'
  end
end

class String
  include StringExtention
end


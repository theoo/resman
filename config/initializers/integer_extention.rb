module IntegerExtention
  def mod10rec
    code = [ 0, 9, 4, 6, 8, 2, 7, 1, 3, 5 ]
    num = 0
    self.to_s.each_char do |char|
        num = code[ (num + char.to_i) % 10 ]
    end
    return (10 - num) % 10
  end
end

class Integer
  include IntegerExtention
end
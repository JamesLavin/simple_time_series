class Array

  def to_i
    map { |str| str.to_i }
  end

  def to_f
    map { |str| str.to_f }
  end

  def to_num
    begin
      to_i
    rescue
      begin
        to_f
      rescue
        raise "Unable to convert #{self} #to_num"
      end
    end
  end
end

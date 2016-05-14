module RestaurantsHelper
  def time_array
    array = Array.new
    (0..24).each do |time|
      array.push(["#{time}:00", time_format(time, false)])
        .push(["#{time}:30", time_format(time)])
    end
    return array
  end

  def time_format(time, half = true)
    time * 100 + (half ? 0 : 30)
  end
end

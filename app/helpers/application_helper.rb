module ApplicationHelper
 def time_array
    array = Array.new
    (0..24).each do |hour|
      array.push(["#{hour}:00", time_format(hour, false)])
        .push(["#{hour}:30", time_format(hour)])
    end
    return array
  end

  def time_format(time, half = true)
    time * 100 + (half ? 0 : 30)
  end

  def time_display(time)
    "#{time / 100}:#{time % 100}"
  end
end

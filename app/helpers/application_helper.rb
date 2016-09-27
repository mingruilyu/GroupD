module ApplicationHelper
  def time_array
    array = Array.new
    (0..23).each do |hour|
      array.push(["#{hour}:00", time_format(hour)])
        .push(["#{hour}:30", time_format(hour, half = true)])
    end
    return array
  end

  def time_format(time, half = false)
    time * 100 + (half ? 30 : 0)
  end

  def time_display(time)
    "#{time / 100}:#{time % 100}"
  end

  def resource
    @resource ||= Account.new
  end

  def resource_name
    :account
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:account]
  end
end

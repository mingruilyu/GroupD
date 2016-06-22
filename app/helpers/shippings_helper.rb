module ShippingsHelper
  def date_array(days_after = 3)
    today = Time.now.day
    array = Array.new
    (1..days_after).each do |day|
      array.push(["#{day + today}", day + today])
    end
    return array
  end
end

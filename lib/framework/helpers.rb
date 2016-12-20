module Helpers
  def self.timeint_to_time(int)
    # MMddHHmm: 12031230 means Dec, 3rd, 12:30     
    Time.now.change(month: int / 1000000, min: int % 100,
      day: (int % 1000000) / 10000, hour: (int % 10000) / 100)  
  end

end

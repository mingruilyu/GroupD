class TestPrintJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    # Do something later
    puts args.to_s
  end
end

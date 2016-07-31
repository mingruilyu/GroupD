class Task
  def self.print_test
    puts 'This is a print test'
  end

  def self.active_job
    TestPrintJob.perform_later 'Test'
  end
end

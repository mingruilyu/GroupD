FactoryGirl.define do
  factory :upload_file do
    payload Rack::Test::UploadedFile.new(File.open(File.join(
      Rails.root, '/test/fixtures/upload_file')))
  end
end

require 'aws-sdk-v1'
require 'aws-sdk'
Services::AwsS3.setup do |config|
  config.use_simulation = (ENV['RAILS_ENV'] == 'test')

  AWS.config(
    :access_key_id => ENV['AWS_ACCESS_ID'], 
    :secret_access_key => ENV['AWS_ACCESS_KEY']
  )

  config.bucket =  AWS::S3.new.buckets['dpool']

  config.simulation_uri = 'test/upload/uploaded'
end

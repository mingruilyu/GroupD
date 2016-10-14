require 'aws-sdk-v1'
require 'aws-sdk'
AWS.config(
  :access_key_id => ENV['AWS_ACCESS_ID'], 
  :secret_access_key => ENV['AWS_ACCESS_KEY']
)

S3_BUCKET =  AWS::S3.new.buckets[ENV['S3_BUCKET']]

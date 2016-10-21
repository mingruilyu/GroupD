module Services
  class GoogleMap
    mattr_accessor :use_simulation
    @@use_simulation = false

    mattr_accessor :api_key
    @@api_key = nil

    mattr_accessor :api_uri
    @@api_uri = nil

    mattr_accessor :simulation_uri
    @@simulation_uri = nil

    def self.setup
      yield self
    end

    def self.location_query(query)
      if @@use_simulation
        puts 'RUNNING GOOGLE MAP SIMULATED REQUEST...'
        path = Rails.root.join @@simulation_uri
        return unless File.exist? path
        (File.new path).read
      else
        puts 'REQUESTING GOOGLE MAP SERVICE FROM ' + @@api_uri
        Request.get @@api_uri, query: query, key: @@api_key
      end
    end
  end

  class AwsS3
    mattr_accessor :use_simulation
    @@use_simulation = false

    mattr_accessor :simulation_uri
    @@simulation_uri = nil

    mattr_accessor :bucket
    @@bucket = nil

    def self.setup
      yield self
    end

    def self.upload_file(file)
      if @@use_simulation
        puts 'RUNNING S3 SIMULATED REQUEST...'
        path = Rails.root.join @@simulation_uri
        des = File.new path, 'w'
        des.write file.read
        UploadFile.new uri: path.to_s, name: file.original_filename
      else
        puts 'REQUESTING S3 SERVICE...'
        s3_object = @@bucket.objects[file.original_filename]
        s3_object.write file: file.payload, acl: :public_read
        UploadFile.new uri: s3_object.public_url, name: s3_object.key     
      end
    end
  end
end

module Request
  class UploadRequest
    def initialize(file)
      @upload_file = UploadFile.new(file)
    end

    def post
      if ENV['RAILS_ENV'] == 'test'
        path = Rails.root.join 'test/upload/uploaded'
        simulation_object = File.new path, 'w'
        simulation_object.write @upload_file.read
        @upload_file.uri = path.to_s
        @upload_file.name = @upload_file.original_filename
      else
        s3_object = S3_BUCKET.objects[
          @upload_file.payload.original_filename]
        s3_object.write file: @upload_file.payload, acl: :public_read
        @upload_file.uri = s3_object.public_url
        @upload_file.name = s3_object.key
      end
      @upload_file
    end
  end

  class JsonRequest
    def initialize(uri, simulation_uri, params={})
      @uri = uri
      @simulation_uri = simulation_uri
      @params = params
    end

    def get
      if ENV['RAILS_ENV'] == 'test'
        puts 'RUNNING SIMULATED REQUEST...'
        path = Rails.root.join @simulation_uri
        return unless File.exist? path 
        (File.new path).read
      elsif
        puts 'REQUESTING FROM SERVICE....'
        uri = URI @uri
        uri.query = URI.encode_www_form @params
        response = Net::HTTP.get_response uri 
        response.body if response.is_a? Net::HTTPSuccess
      end
    end

    def post
      response = Net::HTTP.post_form @uri, @params
      response.body if response.is_a? Net::HTTPSuccess
    end

    def put
    end
  end
end

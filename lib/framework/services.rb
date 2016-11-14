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
        UploadFile.new path.to_s, file.original_filename
      else
        puts 'REQUESTING S3 SERVICE...'
        s3_object = @@bucket.objects[file.original_filename]
        s3_object.write file: file.payload, acl: :public_read
        UploadFile.new s3_object.public_url, s3_object.key     
      end
    end
  end

  class WechatBot

    mattr_accessor :api_token
    @@api_token = nil

    mattr_accessor :bot_id
    @@api_token = '404844425'

    def self.setup
      yield self
    end

    def self.authenticate(token, timestamp, nonce, 
      expected_signature)
      key =  [token, timestamp, nonce].sort.join ''
      signature = Digest::SHA1.hexdigest key
      return signature == expected_signature
    end

    def self.decrypt(text)
    end

    def self.dispatch(message)
      account = self.current_account(message)
      WechatAnalyze.dispatch(message, account) 
    end

    def self.current_account(message)
      Customer.find_by_provider_and_uid('wechat', 
        message.from_user_name)
    end

    def self.construct_message(xml)
      WechatMessage::Message.create Hash.from_xml(xml)['xml']
    end

    def self.assembly_reply(receiver, json)
      WechatReplyAdaptor.adapt json, bot_id, receiver,
        Time.now.to_i
    end
  end

  class QRCodeGenerator
    mattr_accessor :size
    @@size = 120

    def self.setup
      yield self
    end

    def self.generate(data)
      RQRCode::QRCode.new(data).as_png(size: @@size).to_s
    end

    def self.base64_encode(string)
      Base64.encode64 string
    end
  end
end

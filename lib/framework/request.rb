module Request
  class JsonRequest
    def initialize(uri, params={})
      @uri = URI uri
      @params = params
    end

    def get
      @uri.query = URI.encode_www_form @params
      response = Net::HTTP.get_response @uri 
      response.body if response.is_a? Net::HTTPSuccess
    end

    def post
      response = Net::HTTP.post_form @uri, @params
      response.body if response.is_a? Net::HTTPSuccess
    end

    def put
    end
  end

  class Simulation
    def initialize(path)
      @path = Rails.root.join path
    end

    def run
      return unless File.exist? @path
      (File.new @path).read
    end
  end
end

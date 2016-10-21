module Request
  def self.get(uri, params={})
    request_uri = URI uri
    request_uri.query = URI.encode_www_form params
    response = Net::HTTP.get_response request_uri 
    response.body if response.is_a? Net::HTTPSuccess
    end

  def self.post(uri, params={})
    response = Net::HTTP.post_form uri, params
    response.body if response.is_a? Net::HTTPSuccess
  end

  def self.put(uri, params={})
  end
end

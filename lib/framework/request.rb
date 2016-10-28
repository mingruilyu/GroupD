module Request
  def self.get(uri, params=nil, headers={})
    request_uri = URI uri
    if params.present?
      request_uri.query = URI.encode_www_form params
    end
    request = Net::HTTP::Get.new request_uri
    headers.each do |key, val|
      request[key.to_s] = val
    end
    response = Net::HTTP.start(request_uri.hostname, 
      request_uri.port) do |http|
      http.request request
    end
    response.body if response.is_a? Net::HTTPSuccess
    end

  def self.post(uri, params={}, headers={})
    request_uri = URI uri
    request = Net::HTTP::Post.new request_uri
    request.set_form_data params
    headers.each do |key, val|
      request.add_field key.to_s, val
    end
    response = Net::HTTP.start(request_uri.hostname, 
      request_uri.port) do |http|
      http.request(request)
    end
    response.body if response.is_a? Net::HTTPSuccess
  end

  def self.put(uri, params={})
  end
end

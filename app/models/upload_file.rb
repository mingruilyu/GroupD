class UploadFile
  attr_accessor :payload
  attr_accessor :uri
  attr_accessor :name

  MAX_FILE_SIZE = 1.kilobytes

  def initialize(payload)
    @payload = payload
  end

  def original_filename
    @payload.original_filename
  end

  def read
    @payload.read
  end

  def as_json(options={})
    { 'uri': @uri, 'name': @name }
  end
end

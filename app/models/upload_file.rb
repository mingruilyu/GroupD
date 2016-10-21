class UploadFile
  attr_accessor :uri
  attr_accessor :name

  MAX_FILE_SIZE = 1.kilobytes

  def initialize(uri, name)
    @uri = uri
    @name = name
  end

  def as_json(options={})
    { 'uri': @uri, 'name': @name }
  end
end

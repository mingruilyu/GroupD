module Response
  class JsonResponse
    def initialize(object, message={})
      if object
        @object = object
      end
      if message[:notice]
        @message = Message.new :notice, message[:notice]
      elsif message[:warning]
        @message = Message.new :warning, message[:warning]
      elsif message[:error]
        @message = Message.new :error, message[:error]
      end
    end
  end

  class Message
    def initialize level, msgno
      @level = level
      @msgno = msgno
    end
  end
end

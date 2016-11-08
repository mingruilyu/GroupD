class ChatsController < ApplicationController
  before_action :params_sanitization
  before_action :authenticate_account!
  
  def chat
    message = Services::WechatBot.construct_message request.body.read
    operation = Services::WechatBot.dispatch message
    begin
      result = operation.execute
    rescue ActiveRecord::RecordInvalid => e
      result = { error: e.record.errors.messages.values.join("\n") }
    rescue Exceptions::ApplicationError => e
      result = { error: e.message }
    end
    reply = Services::WechatBot.assembly_reply message.from_user_name,
      result
    render xml: reply
  end

  private

    def params_sanitization
      sanitize :chat, nonce: :text, timestamp: :text, 
        signature: :text, msg_signature: :text
    end

    def authenticate_account!
      authorize :chat do
        Services::WechatBot.authenticate(
          Services::WechatBot.api_token, @timestamp, @nonce, 
          @signature)
      end
    end
end

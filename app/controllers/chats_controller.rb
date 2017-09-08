class ChatsController < ApplicationController
  before_action :params_sanitization
  before_action :authenticate_account!
  
  def chat
    message = Services::WechatBot.construct_message request.body.read
    session = Services::WechatBot.get_session message
    operation, args = session.next_operation
    begin
      result = operation.execute args
    rescue ActiveRecord::RecordInvalid => e
      result = { error: e.record.errors.messages.values.join("\n") }
    rescue Exceptions::ApplicationError => e
      result = { error: e.message }
    end
    session.store result
    reply = operation.assembly_reply Services::WechatBot.bot_id, 
      message.from_user_name, result
    render xml: reply
  end

  def configuration
    render plain: @echostr
  end

  private

    def params_sanitization
      sanitize :chat, nonce: :text, timestamp: :text, 
        signature: :text
      sanitize :configuration, nonce: :text, timestamp: :text,
        signature: :text, echostr: :text
    end

    def authenticate_account!
      authorize [:chat, :configuration] do
        Services::WechatBot.authenticate(
          Services::WechatBot.api_token, @timestamp, @nonce, 
          @signature)
      end
    end
end

class ProductChatChannel < ApplicationCable::Channel
  def subscribed
    return unless params[:product_id].present?

    Rails.logger.debug "📡 Subscribed to ProductChatChannel for product #{params[:product_id]}"
    stream_from "product_chat_#{params[:product_id]}"
  end

  def speak(data)
    Rails.logger.debug "💬 Received speak: #{data.inspect}"
    product = Product.find(params[:product_id])
    question = data["message"]

    Thread.new do
      ApplicationRecord.connection_pool.with_connection do
        OllamaService.ask_stream(product, question) do |chunk|
          ActionCable.server.broadcast(
            "product_chat_#{params[:product_id]}",
            { chunk: chunk }
          )
        end
      end
    end
  end
end

require "net/http"
require "json"

class OllamaService
  OLLAMA_API_URL = ENV["OLLAMA_API_URL"]
  EMBEDDING_MODEL = ENV["OLLAMA_EMBEDDING_MODEL"] || "mxbai-embed-large"
  MODEL = ENV["OLLAMA_CHAT_MODEL"] || "llama3"

  class << self
    def generate_embedding(text)
      response = Net::HTTP.post(
        URI(OLLAMA_API_URL + "/embeddings"),
        { model: EMBEDDING_MODEL, prompt: text }.to_json,
        "Content-Type" => "application/json"
      )

      body = JSON.parse(response.body)
      body["embedding"]
    rescue => e
      Rails.logger.error("EmbeddingService failed: #{e.message}")
      nil
    end

    def ask(question)
      response = Net::HTTP.post(
        URI(OLLAMA_API_URL + "/chat"),
        {
          model: MODEL,
          messages: [ { role: "user", content: question } ],
          stream: false
        }.to_json,
        "Content-Type" => "application/json"
      )

      body = JSON.parse(response.body)
      body.dig("message", "content")
    rescue => e
      Rails.logger.error("EmbeddingService failed: #{e.message}")
      nil
    end

    def ask_stream(product, question)
      prompt = <<~PROMPT
        Answer the question using the following product information:
        Name: #{product.name}
        Description: #{product.description}
        Tags: #{product.tags}
        Price: #{product.price}

        Question: #{question}
      PROMPT

      uri = URI("#{OLLAMA_API_URL}/chat")
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = {
        model: MODEL,
        messages: [ { role: "user", content: prompt } ],
        stream: true
      }.to_json

      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request) do |response|
          buffer = ""
          response.read_body do |chunk|
            data = JSON.parse(chunk)
            content = data.dig("message", "content")

            yield content if content.present?
          end
        end
      end
    rescue => e
      Rails.logger.error "Streaming failed: #{e.message}"
    end
  end
end

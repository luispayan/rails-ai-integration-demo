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
  end
end

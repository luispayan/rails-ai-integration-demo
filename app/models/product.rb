class Product < ApplicationRecord
  include ProductsHelper

  def formatted_price
    "$%.2f" % price
  end

  def generate_embedding!
    embedding = normalize_vector(OllamaService.generate_embedding(custom_embedding_context))
    update(embedding: embedding)
  rescue StandardError => e
    Rails.logger.error "Failed to generate embedding for product #{id}: #{e.message}"
    nil
  end

  private

  def custom_embedding_context
    <<~TEXT
      Product Name: #{name}
      Description: #{description}
      Tags: #{tags}
    TEXT
  end
end

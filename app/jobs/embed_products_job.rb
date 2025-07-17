class EmbedProductsJob < ApplicationJob
  queue_as :default

  def perform
    Product.find_each do |product|
      product.generate_embedding!
    end
  end
end

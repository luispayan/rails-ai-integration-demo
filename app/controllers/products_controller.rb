class ProductsController < ApplicationController
  include ProductsHelper

  VECTOR_THRESHOLD = 0.33

  def index
    @pagy, @products = pagy(Product.all)

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("results", partial: "products", locals: { products: @products, pagy: @pagy })
      end
    end
end

  def show
    @product = Product.find(params[:id])
  end

  def search
    query = params[:query] + ", NOTE: this should be related to products"
    embedding = normalize_vector(OllamaService.generate_embedding(query)) if params[:query].present?

    if embedding.present?
      vector_str = "[#{embedding.join(',')}]"

      scope = Product
        .where.not(embedding: nil)
        .where("embedding <=> ?::vector < ?", vector_str, VECTOR_THRESHOLD)
        .order(Arel.sql("embedding <=> '#{vector_str}'::vector"))

      @pagy, @products = pagy(scope, limit: 200, request_path: products_path)
    else
      @pagy, @products = pagy(Product.all, limit: 12, request_path: products_path)
    end

    render turbo_stream: turbo_stream.update("results", partial: "products", locals: { products: @products, pagy: @pagy })
  rescue StandardError => e
    Rails.logger.error "Search failed: #{e.message}"
    @pagy, @products = pagy(Product.none, limit: 12, request_path: products_path)

    render turbo_stream: turbo_stream.update("results", partial: "products", locals: { products: @products, pagy: @pagy })
  end
end

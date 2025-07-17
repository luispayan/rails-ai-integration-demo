class GenerateContextConfigJob < ApplicationJob
  queue_as :default

  def perform
    models_with_embedding.each do |model|
      if model.respond_to?(:generate_context_config!)
        model.generate_context_config!
      else
        Rails.logger.warn("Model #{model.name} does not respond to generate_context_config!")
      end
    end
  end
end

class EmbedAllModels < ApplicationJob
  queue_as :default

  def perform
    models_with_embedding.each do |model|
      model.find_each do |object|
        object.generate_dynamic_embedding!
      end
    end
  end
end

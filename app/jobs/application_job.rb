class ApplicationJob < ActiveJob::Base
  private

  def models_with_embedding
    Rails.application.eager_load!

    ActiveRecord::Base.descendants.select do |model|
      model.table_exists? && model.column_names.include?("embedding")
    end
  end
end

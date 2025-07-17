# frozen_string_literal: true

module Embeddable
  extend ActiveSupport::Concern

  def generate_dynamic_embedding!
    embedding = VectorService.normalize_vector(OllamaService.generate_embedding(embedding_context))
    update(embedding: embedding)
  rescue StandardError => e
    Rails.logger.error "Failed to generate embedding for #{self.class.name} #{id}: #{e.message}"
    nil
  end

  private

  def embedding_context
    if respond_to?(:custom_embedding_context)
      custom_embedding_context
    else
      render_embedding_from_yaml
    end
  end

  def render_embedding_from_yaml
    yaml_path = Rails.root.join("config/embeddings.yml")
    @embedding_templates ||= YAML.load_file(yaml_path)

    template = @embedding_templates[self.class.name]&.dig("content")
    template ||= generate_context_config(yaml_path)

    ERB.new(template).result(binding)
  end

  def generate_context_config(yaml_path)
    template = self.class.generate_template_with_llama!
    self.class.update_embedding_yaml(yaml_path, self.class.name, template)
    template
  end

  class_methods do
    def generate_context_config!
      yaml_path = Rails.root.join("config/embeddings.yml")
      template = generate_template_with_llama!

      update_embedding_yaml(yaml_path, name, template)
      Rails.logger.info "Embedding context for #{name} written to config/embeddings.yml"

      template
    end

    def generate_template_with_llama!
      prompt = <<~PROMPT
        You are an assistant generating ERB templates for Ruby on Rails models.

        I have a model named "#{name}" with the following attributes:

        #{column_names.join(', ')}

        I want to generate a YAML-compatible ERB block for semantic embedding. The YAML structure would look like this:

        ModelName:
          content: |
            Attribute1: <%= attribute1 %>
            Attribute2: <%= attribute2 %>

        For example, for a model `Product` with attributes `name`, `description`, and `tags`, the output should be:

            Name: <%= name %>
            Description: <%= description %>
            Tags: <%= tags %>

        ⚠️ IMPORTANT:
        - Use the most relevant attributes. Avoid IDs, timestamps, embedding, or foreign keys unless they’re meaningful.
        - Return **only** the ERB block that would go under `content: |`
        - Do NOT add any introductory text, explanation, or code comments.
        - Do NOT wrap the output in quotes.
        - Do NOT escape characters like \\n — use real newlines.
        - Output must start directly with the first attribute label.
        - Output should not has anything after the last attribute label.

        Begin output now.
      PROMPT

      OllamaService.ask(prompt)
        .lines
        .reject { |line| line.strip.downcase.start_with?("here", "erb", "for", "content") }
        .join.strip
        .split("\n\n").first
    end

    def update_embedding_yaml(path, model_name, content)
      yaml_data = File.exist?(path) ? YAML.load_file(path) : {}
      yaml_data[model_name] = { "content" => content }
      File.write(path, yaml_data.to_yaml)
    end
  end
end

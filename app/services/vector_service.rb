class VectorService
  class << self
    def normalize_vector(vector)
      norm = Math.sqrt(vector.sum { |x| x.to_f**2 })
      return vector if norm.zero?

      vector.map { |x| x.to_f / norm }
    end

    def normalized?(embedding, epsilon = 1e-6)
      l2_norm = Math.sqrt(embedding.sum { |x| x**2 })
      (l2_norm - 1.0).abs < epsilon
    end
  end
end

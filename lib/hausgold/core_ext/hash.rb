# frozen_string_literal: true

# All our Ruby core extensions for the +Hash+ class.
class Hash
  # Perform the regular +Hash#compact+ method on the object but takes care of
  # deeply nested hashs.
  #
  # @return [Hash]
  def deep_compact
    deep_compact_in_object(self)
  end

  private

  # A supporting helper to allow deep hash compaction.
  #
  # @param object [Mixed] the object to compact
  # @return [Mixed] the compacted object
  def deep_compact_in_object(object)
    case object
    when Hash
      object.compact.each_with_object({}) do |(key, value), result|
        result[key] = deep_compact_in_object(value)
      end
    when Array
      object.map { |item| deep_compact_in_object(item) }
    else
      object
    end
  end
end

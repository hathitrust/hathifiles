# frozen_string_literal: true

require 'services'

module RightsDatabase
  class Attribute
    attr_reader :id, :type, :name, :description

    def initialize(id:, type:, name:, dscr:)
      @id = id
      @type = type
      @name = name
      @description = dscr
    end
  end

  # Rights Attributes
  class RightsAttributes
    attr_accessor :attributes

    def initialize(attributes = load_from_db)
      @attributes = attributes
    end

    def load_from_db
      Services.rights_db[:attributes]
              .select(:id,
                      :type,
                      :name,
                      :dscr)
              .as_hash(:id)
              .transform_values { |h| Attribute.new(h) }
    end

    def [](attr)
      @attributes[attr]
    end
  end
end

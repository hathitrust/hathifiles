# frozen_string_literal: true

require "services"

module CollectionsDatabase
  # An individual Collection record
  class Collection
    attr_reader :collection, :content_provider_cluster, :responsible_entity,
      :original_from_inst_id, :billing_entity

    def initialize(collection:, content_provider_cluster:, responsible_entity:,
      original_from_inst_id:, billing_entity:)
      @collection = collection
      @content_provider_cluster = content_provider_cluster
      @responsible_entity = responsible_entity
      @original_from_inst_id = original_from_inst_id
      @billing_entity = billing_entity
    end
  end

  #
  # Cache of information about HathiTrust collections.
  #
  # Usage:
  #
  #  htc = Collections.new()
  #  be = htc["MIU"].billing_entity
  #
  # This reeturns a hash keyed by collection code that contains the collection code,
  # content provider cluster, responsible entity, orginal_from_inst_id, and billing entity.
  class Collections
    attr_reader :collections

    def initialize(collections = load_from_db)
      @collections = collections
    end

    def load_from_db
      Services.db[:ht_collections]
        .select(:collection,
          :content_provider_cluster,
          :responsible_entity,
          :original_from_inst_id,
          :billing_entity)
        .as_hash(:collection)
        .transform_values { |h| Collection.new(**h) }
    end

    def [](collection)
      if @collections.key?(collection)
        @collections[collection]
      else
        raise KeyError, "No collection data for collection:#{collection}"
      end
    end

    def each
      return enum_for(:each) unless block_given?

      @collections.each { |collection_code, collection| yield [collection_code, collection] }
    end
  end
end

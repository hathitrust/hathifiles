# frozen_string_literal: true

require 'services'

module RightsDatabase
  # Rights for an individual HT item
  class Rights
    attr_accessor :item_id, :attribute, :reason, :source, :time, :note, :access_profile, :user, :namespace, :id

    def initialize(item_id:, attribute: nil, reason: nil, source: nil, time: nil, note: nil, access_profile: nil,
                   user: nil)
      @item_id = item_id
      @namespace, @id = @item_id.split(/\./, 2)
      if @attribute.nil?
        load_from_db
      else
        @attribute = attribute
        @reason = reason
        @source = source
        @time = time
        @note = note
        @access_profile = access_profile
        @user = user
      end
    end

    def load_from_db
      rights = Services.rights_db[:rights_current]
                       .where(namespace: namespace, Sequel.qualify(:rights_current, :id) => id)
                       .first
      rights.each do |k, v|
        case k
        when :reason
          @reason = Services.rights_reasons[v]
        when :attr
          @attribute = Services.rights_attributes[v]
        else
          public_send("#{k}=", v)
        end
      end
    end
  end
end

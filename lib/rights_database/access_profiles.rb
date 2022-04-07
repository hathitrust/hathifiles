# frozen_string_literal: true

require "services"

module RightsDatabase
  # Access Profile
  # Pulled from the access_profiles table.
  # A join when pulling an items rights would also work? (better)
  class AccessProfile
    attr_reader :id, :name, :dscr

    def initialize(id:, name:, dscr:)
      @id = id
      @name = name
      @description = dscr
    end
  end

  class AccessProfiles
    attr_accessor :profiles

    def initialize(profiles = load_from_db)
      @profiles = profiles
    end

    def load_from_db
      Services.rights_db[:access_profiles]
        .select(:id,
          :name,
          :dscr)
        .as_hash(:id)
        .transform_values { |h| AccessProfile.new(h) }
    end

    def [](profile_id)
      @profiles[profile_id]
    end
  end
end

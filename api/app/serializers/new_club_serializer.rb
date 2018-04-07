# frozen_string_literal: true

class NewClubSerializer < ActiveModel::Serializer
  attributes :id,
             :created_at,
             :updated_at,
             :high_school_name,
             :high_school_url,
             :high_school_type,
             :high_school_address,
             :high_school_latitude,
             :high_school_longitude,
             :high_school_parsed_address,
             :high_school_parsed_city,
             :high_school_parsed_state,
             :high_school_parsed_state_code,
             :high_school_parsed_postal_code,
             :high_school_parsed_country,
             :high_school_parsed_country_code

  has_many :new_leaders
end

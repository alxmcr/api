# frozen_string_literal: true

module V1
  class EventsController < ApiController
    USER_AUTH = { except: [:index] }.freeze
    include UserAuth

    def index
      render_success Event.all.includes(
        logo: [file_attachment: :blob],
        banner: [file_attachment: :blob]
      )
    end

    def create
      event = Event.new(event_params)
      authorize event

      if event.save
        render_success event, 201
      else
        render_field_errors event.errors
      end
    end

    def update
      event = Event.find(params[:id])
      authorize event

      event.assign_attributes(event_params)
      event.logo = logo if logo
      event.banner = banner if banner

      if event.save
        render_success(event)
      else
        render_field_errors(event.errors)
      end
    end

    private

    def event_params
      params.permit(
        :start,
        :end,
        :name,
        :website,
        :total_attendance,
        :first_time_hackathon_estimate,
        :address
      )
    end

    def logo
      id = params[:logo_id]
      EventLogo.find(id) if id
    end

    def banner
      id = params[:banner_id]
      EventBanner.find(id) if id
    end
  end
end
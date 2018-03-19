# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Events', type: :request do
  describe 'GET /v1/events' do
    before { 5.times { create(:event_w_photos) } }

    it 'properly lists events' do
      get '/v1/events'
      expect(response.status).to eq(200)

      # returns all events
      expect(json.length).to eq(5)

      # returns proper attributes
      expect(json[0]).to include(
        'id',
        'created_at',
        'updated_at',
        'start',
        'end',
        'name',
        'website',
        'address',
        'latitude',
        'longitude',
        'parsed_address',
        'parsed_city',
        'parsed_state',
        'parsed_state_code',
        'parsed_postal_code',
        'parsed_country',
        'parsed_country_code'
      )
      expect(json[0]['logo']).to include(
        'id', 'created_at', 'updated_at', 'file_path',
        'type' => 'event_logo'
      )
      expect(json[0]['banner']).to include(
        'id', 'created_at', 'updated_at', 'file_path',
        'type' => 'event_banner'
      )
    end
  end

  describe 'POST /v1/events' do
    let(:user) { create(:user_authed) }
    let(:auth_headers) { { 'Authorization': "Bearer #{user.auth_token}" } }

    it 'requires authentication' do
      post '/v1/events'
      expect(response.status).to eq(401)
    end

    it 'requires admin' do
      post '/v1/events', headers: auth_headers
      expect(response.status).to eq(403)
    end

    context 'as admin' do
      let(:user) { create(:user_admin_authed) }

      it 'successfully creates new events' do
        expect do
          post '/v1/events',
               headers: auth_headers,
               params: attributes_for(:event)
        end.to change { Event.count }.by(1)
      end

      it 'allows setting the proper fields' do
        post '/v1/events',
             headers: auth_headers,
             params: {
               start: 3.days.from_now,
               end: 4.days.from_now,
               name: 'TestHacks',
               website: 'https://example.com',
               total_attendance: 100,
               first_time_hackathon_estimate: 120,
               address: 'Test Address'
             }

        expect(response.status).to eq(201)
        expect(json).to include(
          'start' => 3.days.from_now.to_date.to_s,
          'end' => 4.days.from_now.to_date.to_s,
          'name' => 'TestHacks',
          'website' => 'https://example.com',
          'total_attendance' => 100,
          'first_time_hackathon_estimate' => 120,
          'address' => 'Test Address'
        )
      end

      it 'throws validation errors when needed' do
        post '/v1/events',
             headers: auth_headers,
             params: {
               name: 'Test'
             }

        expect(response.status).to eq(422)
        expect(json['errors']).to include('address')
      end
    end
  end

  describe 'PATCH /v1/events/:id' do
    let(:event) { create(:event) }

    let(:user) { nil } # set this in subtests
    let(:auth_headers) { { 'Authorization': "Bearer #{user.auth_token}" } }

    it 'requires authentication' do
      patch "/v1/events/#{event.id}", params: { name: 'TestEvent' }
      expect(response.status).to eq(401)
    end

    context 'when authenticated as non-admin' do
      let(:user) { create(:user_authed) }

      it 'fails' do
        patch "/v1/events/#{event.id}",
              headers: auth_headers,
              params: { name: 'TestEvent' }
        expect(response.status).to eq(403)
      end
    end

    context 'when authenticated as admin' do
      let(:user) { create(:user_admin_authed) }

      context 'with valid params' do
        let(:params) { { name: 'TestEvent' } }

        before do
          patch "/v1/events/#{event.id}",
                headers: auth_headers,
                params: params
        end

        it 'succeeds' do
          expect(response.status).to eq(200)
          expect(json['name']).to eq('TestEvent')
        end

        context 'and trying to update banner / logo' do
          let(:logo) { create(:event_logo) }
          let(:banner) { create(:event_banner) }

          let(:params) do
            {
              logo_id: logo.id,
              banner_id: banner.id
            }
          end

          it 'successfully updates' do
            expect(response.status).to eq(200)
            expect(json['logo']['id']).to eq(logo.id)
            expect(json['banner']['id']).to eq(banner.id)
          end
        end
      end

      context 'with invalid params' do
        let(:params) { { name: nil } }

        before do
          patch "/v1/events/#{event.id}",
                headers: auth_headers,
                params: params
        end

        it 'fails gracefully' do
          expect(response.status).to eq(422)
          expect(json['errors']).to include('name')
        end
      end
    end
  end
end
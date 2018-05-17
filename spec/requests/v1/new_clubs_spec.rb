# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::NewClubs', type: :request do
  let(:user) { nil } # set this in subtests
  let(:auth_headers) { { 'Authorization': "Bearer #{user.auth_token}" } }

  # set these in subtests
  let(:params) { {} }
  let(:headers) { {} }
  let(:method) { :get }
  let(:url) { '' }
  let(:setup) {} # override this to do any setup you'd usually do in before

  before do
    setup
    send(method, url, params: params, headers: headers)
  end

  describe 'GET /v1/new_clubs' do
    let(:method) { :get }
    let(:url) { '/v1/new_clubs' }

    let(:setup) { 5.times { create(:new_club_w_leaders, leader_count: 3) } }

    it 'requires authentication' do
      expect(response.status).to eq(401)
    end

    context 'when authenticated' do
      let(:user) { create(:user_authed) }
      let(:headers) { auth_headers }

      it 'requires admin' do
        expect(response.status).to eq(403)
      end

      context 'as admin' do
        let(:user) { create(:user_admin_authed) }

        it 'succeeds' do
          expect(response.status).to eq(200)
          expect(json.length).to eq(5)
        end

        it 'includes leadership positions & profiles' do
          club = json[0]

          expect(club['new_leaders'].length).to eq(3)
          expect(club['new_leaders'][0]).to include('id')
        end
      end
    end
  end

  describe 'PATCH /v1/new_clubs/:id' do
    let(:club) { create(:new_club) }

    let(:method) { :patch }
    let(:url) { "/v1/new_clubs/#{club.id}" }
    let(:params) do
      {
        high_school_name: 'Sample School',
        high_school_type: :private_school,
        high_school_address: 'Fake Street, NYC'
      }
    end

    it 'requires authentication' do
      expect(response.status).to eq(401)
    end

    context 'when authenticated' do
      let(:user) { create(:user_authed) }
      let(:headers) { auth_headers }

      it 'requires admin or leadership position' do
        expect(response.status).to eq(403)
      end

      context 'as admin' do
        let(:user) { create(:user_admin_authed) }

        it 'succeeds' do
          expect(response.status).to eq(200)
          expect(json).to include(
            'high_school_name' => 'Sample School',
            'high_school_type' => 'private_school',
            'high_school_address' => 'Fake Street, NYC'
          )
        end

        context 'with invalid params' do
          let(:params) do
            {
              high_school_name: nil
            }
          end

          it 'gracefully fails' do
            expect(response.status).to eq(422)
            expect(json['errors']).to include('high_school_name')
          end
        end
      end

      context 'with leadership position' do
        let(:setup) { club.new_leaders << create(:new_leader, user: user) }

        it 'succeeds' do
          expect(response.status).to eq(200)
        end
      end
    end
  end
end

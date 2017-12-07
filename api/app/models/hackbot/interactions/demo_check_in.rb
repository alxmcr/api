# This command is for demoing Hackbot's check-in interaction to potential
# donors. It should never trigger for anyone but the demo user.

module Hackbot
  module Interactions
    class DemoCheckIn < Command
      include Concerns::LeaderAssociable

      TRIGGER = /i had a club meeting/

      STREAK_KEY = Rails.application.secrets.streak_demo_user_box_key

      def should_start?
        # Only run the check in if the command comes from the demo user
        super && slack_id == event[:user]
      end

      def start
        # Close unfinished check-ins from this user before starting a new
        # check-in interaction
        CloseCheckInsJob.perform_now check_in_interaction_ids

        msg_channel "I'll send you a check in!"
        LeaderCheckInJob.perform_now STREAK_KEY
      end

      private

      def slack_id
        Leader.find_by(streak_key: STREAK_KEY).slack_id
      end

      def check_in_interaction_ids
        access_token = Hackbot::Team
                       .find_by(team_id: team.team_id)
                       .bot_access_token

        im_id = SlackClient::Chat.open_im(slack_id, access_token)[:channel][:id]

        check_in_interactions = Hackbot::Interactions::CheckIn
                                .where("data->>'channel' = ?", im_id)
                                .where.not(state: 'finish')

        check_in_interactions.map(&:id)
      end
    end
  end
end

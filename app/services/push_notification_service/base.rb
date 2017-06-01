module PushNotificationService
  class Base
    ONE_SIGNAL_BATCH_SIZE = 2000

    # This should match any RFC4122 UUID
    PLAYER_ID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i

    def query_batch_size
      Integer(ENV['ONE_SIGNAL_BATCH_SIZE'] || ONE_SIGNAL_BATCH_SIZE)
    end

    def send_notification(player_ids, params)
      # Ensure we only send valid player_ids, so the One Signal does not error.
      player_ids = player_ids.select { |id| id[PLAYER_ID_REGEX] }

      OneSignal::Notification.create(params: {
        app_id: ENV['ONE_SIGNAL_APP_ID'],
        include_player_ids: player_ids.first(ONE_SIGNAL_BATCH_SIZE)
      }.merge(params))
    end
  end
end

module PushNotificationService
  class Base
    ONE_SIGNAL_BATCH_SIZE = 2000

    def query_batch_size
      Integer(ENV['ONE_SIGNAL_BATCH_SIZE'] || ONE_SIGNAL_BATCH_SIZE)
    end

    def send_notification(player_ids, params)
      OneSignal::Notification.create(params: {
        app_id: ENV['ONE_SIGNAL_APP_ID'],
        include_player_ids: player_ids.first(ONE_SIGNAL_BATCH_SIZE)
      }.merge(params))
    end
  end
end

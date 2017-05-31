class PushNotificationService
  def new_follower_notification(recipient, new_follower)
    return if recipient.devices.none?

    delay.send_notification(
      recipient,
      headings: { en: 'You have a new follower' },
      contents: { en: "You are now being followed by #{new_follower.handle}" },
      data: { follower_id: new_follower.id, env: Rails.env }
    )
  end

  def send_notification(recipient, params)
    OneSignal::Notification.create(params: {
      app_id: ENV['ONE_SIGNAL_APP_ID'],
      include_player_ids: recipient.devices.map(&:player_id)
    }.merge(params))
  end
end

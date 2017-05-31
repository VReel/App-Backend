class PushNotificationService
  # We assume any give batch of 500 users will not have more than 2000 device ids.
  # I guess that's pretty unlikely.
  QUERY_BATCH_SIZE = 500
  ONE_SIGNAL_BATCH_SIZE = 2000

  def query_batch_size
    Integer(ENV['ONE_SIGNAL_QUERY_BATCH_SIZE'] || QUERY_BATCH_SIZE)
  end

  def new_follower_notification(recipient, new_follower)
    return if recipient.devices.none?

    delay.send_notification(
      recipient.device_ids,
      headings: { en: I18n.t('push_notifications.new_follower.title') },
      contents: { en: I18n.t('push_notifications.new_follower.body', new_follower_handle: new_follower.handle) },
      data: { follower_id: new_follower.id, env: Rails.env }
    )
  end

  def new_post_notification(post)
    return if post.user.followers.none?

    delay.notify_users_in_batches(post)
  end

  def notify_users_in_batches(post)
    post.user.followers.find_in_batches(batch_size: query_batch_size).each do |follower_batch|
      device_ids = follower_batch.map(&:device_ids).flatten

      next if device_ids.none?

      delay.send_notification(
        device_ids,
        headings: { en: I18n.t('push_notifications.new_post.title') },
        contents: { en: new_post_notification_body(post) },
        data: { post_id: post.id, env: Rails.env }
      )
    end
  end

  def new_post_notification_body(post)
    if post.caption.present?
      I18n.t('push_notifications.new_post.body_with_caption', poster_handle: post.user.handle, post_caption: post.caption)
    else
      I18n.t('push_notifications.new_post.body_without_caption', poster_handle: post.user.handle)
    end
  end

  def send_notification(player_ids, params)
    OneSignal::Notification.create(params: {
      app_id: ENV['ONE_SIGNAL_APP_ID'],
      include_player_ids: player_ids.first(ONE_SIGNAL_BATCH_SIZE)
    }.merge(params))
  end
end

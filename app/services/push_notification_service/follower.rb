module PushNotificationService
  class Follower < Base
    def call(recipient, new_follower)
      return if recipient.devices.none?

      delay.send_notification(
        recipient.device_ids,
        headings: { en: I18n.t('push_notifications.new_follower.title') },
        contents: { en: I18n.t('push_notifications.new_follower.body', new_follower_handle: new_follower.handle) },
        data: { follower_id: new_follower.id, env: Rails.env }
      )
    end
  end
end

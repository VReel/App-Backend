module PushNotificationService
  class Post < Base
    attr_reader :post

    def call(post)
      return if post.user.followers.none?

      @post = post

      delay.notify_users_in_batches
    end

    def notify_users_in_batches
      device_ids_query.find_in_batches(batch_size: query_batch_size).each do |devices|
        next if devices.none?

        delay.send_notification(
          devices.map(&:player_id),
          headings: { en: I18n.t('push_notifications.new_post.title') },
          contents: { en: notification_body },
          data: { post_id: post.id, env: Rails.env }
        )
      end
    end

    def device_ids_query
      Device.where('user_id IN (SELECT follower_id FROM follows WHERE following_id = ?)', post.user.id)
    end

    def notification_body
      if post.caption.present?
        I18n.t('push_notifications.new_post.body_with_caption', poster_handle: post.user.handle, post_caption: post.caption)
      else
        I18n.t('push_notifications.new_post.body_without_caption', poster_handle: post.user.handle)
      end
    end
  end
end

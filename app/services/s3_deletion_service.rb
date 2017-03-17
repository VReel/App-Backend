class S3DeletionService
  def delete(key)
    # No real assets in test.
    return if Rails.env.test?

    # This seem to respond the same way whether the key exists or not.
    S3_BUCKET.object(key).delete
  end

  def delete_folder(folder)
    # No real assets in test.
    return if Rails.env.test?

    keys = S3_BUCKET.objects(prefix: folder).map(&:key)

    # If there is nothing to delete we are done.
    return unless keys.any?

    S3_BUCKET.delete_objects(delete: {
      objects: keys.map { |key| { key: key } }
    })

    Rails.logger.info "Deleted #{keys.size} objects"

    # Recurse in case there are more.
    delete_folder(folder)
  end
end

class S3DeletionService
  def delete(key)
    # No real assets in test.
    return if Rails.env.test?

    # This seem to respond the same way whether the key exists or not.
    S3_BUCKET.object(key).delete
  end

  def bulk_delete(keys)
    # No real assets in test.
    return if Rails.env.test?
    return unless keys.any?

    S3_BUCKET.delete_objects(delete: {
      objects: keys.map { |key| { key: key } }
    })

    Rails.logger.info "Deleted #{keys.size} objects"
  end
end

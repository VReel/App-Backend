class S3DeletionService
  def delete(key)
    # No real assets in test.
    return if Rails.env.test?

    # This seem to respond the same way whether the key exists or not.
    S3_BUCKET.object(key).delete
  end
end

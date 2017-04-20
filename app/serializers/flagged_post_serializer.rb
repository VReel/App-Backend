class FlaggedPostSerializer < PostSerializer
  attributes :id,
             :thumbnail_url,
             :caption,
             :like_count,
             :comment_count,
             :created_at,
             :edited,
             :original_url,
             :edited,
             :flag_count

  def flag_count
    return object.flags.where(status: :awaiting).count if instance_options[:flag_counts].nil?

    instance_options[:flag_counts][object.id]
  end

  def liked_by_me
    nil
  end
end

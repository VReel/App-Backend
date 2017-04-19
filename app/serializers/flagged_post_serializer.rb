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

  has_many :flags

  def flag_count
    object.flags.where(status: :awaiting).count
  end

  def liked_by_me
    nil
  end
end

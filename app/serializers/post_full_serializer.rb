class PostFullSerializer < PostSerializer
  attributes :id,
             :thumbnail_url,
             :caption,
             :like_count,
             :comment_count,
             :created_at,
             :edited,
             :original_url,
             :edited,
             :liked_by_me
end

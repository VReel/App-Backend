class AdminDoc
  include Swagger::Blocks

  swagger_path '/admin/stats' do
    operation :get do
      key :summary, 'Get summary system stats'
      key :description, 'Authorized chiefs only'
      key :operationId, 'stats'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Admin'
      ]
      parameter do
        key :in, :query
        key :name, :date_from
        key :description, 'Start date for query. Any sensible time format but ISO8601 is good.'
        key :required, false
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :date_to
        key :description, 'End date for query. Any sensible time format but ISO8601 is good.'
        key :required, false
        key :type, :string
      end
    end
  end

  swagger_path '/admin/flagged_posts' do
    operation :get do
      key :summary, 'Get flagged_posts'
      key :description, 'Authorized chiefs only'
      key :operationId, 'flagged_posts'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Admin'
      ]
      parameter do
        key :in, :query
        key :name, :page
        key :description, 'Gets next page of flagged posts.'
        key :required, false
        key :type, :string
      end
    end
  end

  swagger_path '/admin/flagged_posts/{postId}/flags' do
    operation :get do
      key :summary, 'Get flags for a flagged_post'
      key :description, 'Authorized chiefs only'
      key :operationId, 'flagged_posts_flags'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Admin'
      ]
      parameter do
        key :in, :query
        key :name, :page
        key :description, 'Gets next page of flag.'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :postId
        key :in, :path
        key :description, 'ID of post to update'
        key :required, true
        key :type, :string
      end
    end
  end


  swagger_path '/admin/users' do
    operation :get do
      key :summary, 'Get all posts'
      key :description, 'Authorized chiefs only'
      key :operationId, 'admin_users'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Admin'
      ]
      parameter do
        key :in, :query
        key :name, :page
        key :description, 'Gets next page of users.'
        key :required, false
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :sort
        key :description, 'Order users.'
        key :required, false
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :date_from
        key :description, 'Gets users registered from this date.'
        key :required, false
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :date_to
        key :description, 'Gets users registered to this date.'
        key :required, false
        key :type, :string
      end
    end
  end

  swagger_path '/admin/posts' do
    operation :get do
      key :summary, 'Get all posts'
      key :description, 'Authorized chiefs only'
      key :operationId, 'admin_posts'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Admin'
      ]
      parameter do
        key :in, :query
        key :name, :page
        key :description, 'Gets next page of posts.'
        key :required, false
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :sort
        key :description, 'Order posts.'
        key :required, false
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :date_from
        key :description, 'Gets posts from this date.'
        key :required, false
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :date_to
        key :description, 'Gets posts to this date.'
        key :required, false
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :min_comments
        key :description, 'Gets posts with at least this number of comments.'
        key :required, false
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :max_comments
        key :description, 'Gets posts with at most this number of comments.'
        key :required, false
        key :type, :string
      end
       parameter do
        key :in, :query
        key :name, :min_likes
        key :description, 'Gets posts with at least this number of likes.'
        key :required, false
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :max_likes
        key :description, 'Gets posts with at most this number of likes.'
        key :required, false
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :user
        key :description, 'Get posts by this user (handle).'
        key :required, false
        key :type, :string
      end
    end



  end
end

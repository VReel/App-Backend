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
    end
  end
end

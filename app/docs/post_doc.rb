class PostDoc
  include Swagger::Blocks

  swagger_schema :Post do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :thumbnail_key do
      key :type, :string
    end
    property :original_key do
      key :type, :string
    end
    property :caption do
      key :type, :string
    end
  end

  swagger_path '/posts' do
    operation :get do
      key :summary, 'Get all posts by user'
      key :operationId, 'get_posts'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Post'
      ]
      parameter do
        key :in, :query
        key :name, :created_before
        key :description, 'Get posts created before this timestamp. Used for pagination. ISO8601 format
          (but actually any sensible timeformat should work)'
        key :required, false
        key :type, :string
      end
    end
    operation :post do
      key :summary, 'Create new post'
      key :operationId, 'create_post'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Post'
      ]
      parameter do
        key :in, :body
        key :name, :body
        key :description, 'Post object to be created'
        key :required, true
        schema do
          key :'$ref', :PostInput
        end
      end
    end
  end

  swagger_path '/posts/{postId}' do
    operation :get do
      key :summary, 'Show a post'
      key :description, 'Shows the full post data'
      key :operationId, 'get_post'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Post'
      ]
      parameter do
        key :name, :postId
        key :in, :path
        key :description, 'ID of post to update'
        key :required, true
        key :type, :string
      end
    end
    operation :put do
      key :summary, 'Update a post'
      key :description, 'Only captions can be updated'
      key :operationId, 'update_post'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Post'
      ]
      parameter do
        key :name, :postId
        key :in, :path
        key :description, 'ID of post to update'
        key :required, true
        key :type, :string
      end
      parameter do
        key :in, :body
        key :name, :body
        key :description, 'Post object to be updated'
        key :required, true
        schema do
          key :'$ref', :PostUpdateInput
        end
      end
    end
  end

  swagger_path '/posts/{postId}' do
    operation :delete do
      key :summary, 'Delete a post'
      key :operationId, 'delete_post'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Post'
      ]
      parameter do
        key :name, :postId
        key :in, :path
        key :description, 'ID of post to delete'
        key :required, true
        key :type, :string
      end
    end
  end

  swagger_schema :PostInput do
    allOf do
      schema do
        key :required, [:thumbnail_key, :original_key]
        property :thumbnail_key do
          key :type, :string
        end
        property :original_key do
          key :type, :string
        end
        property :caption do
          key :type, :string
        end
      end
    end
  end

  swagger_schema :PostUpdateInput do
    allOf do
      schema do
        key :required, [:caption]
        property :caption do
          key :type, :string
        end
      end
    end
  end
end

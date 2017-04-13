class CommentDoc
  include Swagger::Blocks

  swagger_schema :Comment do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :text do
      key :type, :string
    end
  end

  swagger_path '/posts/{postId}/comments' do
    operation :get do
      key :summary, 'Get page of comments on a post'
      key :operationId, 'get_post_comments'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Post'
      ]
      parameter do
        key :name, :postId
        key :in, :path
        key :description, 'ID of post to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :page
        key :description, 'Gets next page of comments.'
        key :required, false
        key :type, :string
      end
    end
    operation :post do
      key :summary, 'Create new comment'
      key :operationId, 'create_comment'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Comment'
      ]
      parameter do
        key :name, :postId
        key :in, :path
        key :description, 'ID of post to'
        key :required, true
        key :type, :string
      end
      parameter do
        key :in, :body
        key :name, :body
        key :description, 'Comment object to be created'
        key :required, true
        schema do
          key :'$ref', :CommentInput
        end
      end
    end
  end

  swagger_path '/comments/{commentId}' do
    operation :put do
      key :summary, 'Update a comment'
      key :operationId, 'update_comment'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Comment'
      ]
      parameter do
        key :name, :commentId
        key :in, :path
        key :description, 'ID of comment to update'
        key :required, true
        key :type, :string
      end
      parameter do
        key :in, :body
        key :name, :body
        key :description, 'Comment object to be updated'
        key :required, true
        schema do
          key :'$ref', :CommentInput
        end
      end
    end
    operation :delete do
      key :summary, 'Delete a comment'
      key :operationId, 'delete_comment'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Comment'
      ]
      parameter do
        key :name, :commentId
        key :in, :path
        key :description, 'ID of comment to update'
        key :required, true
        key :type, :string
      end
    end
  end

  swagger_schema :CommentInput do
    allOf do
      schema do
        key :required, [:text]
        property :text do
          key :type, :string
        end
      end
    end
  end
end

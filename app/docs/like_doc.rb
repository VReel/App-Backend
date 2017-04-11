class LikeDoc
  include Swagger::Blocks

  swagger_path '/like/{post_id}' do
    operation :post do
      key :summary, 'Like a post'
      key :operationId, 'like_post'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Like'
      ]
      parameter do
        key :in, :path
        key :name, :post_id
        key :description, 'UUID of the post to like.'
        key :required, true
        key :type, :string
      end
    end

    operation :delete do
      key :summary, 'Unlike a post'
      key :operationId, 'unlike_post'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Like'
      ]
      parameter do
        key :in, :path
        key :name, :post_id
        key :description, 'UUID of the post to unlike.'
        key :required, true
        key :type, :string
      end
    end
  end
end

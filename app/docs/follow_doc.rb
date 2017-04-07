class FollowDoc
  include Swagger::Blocks

  swagger_path '/follow/{user_id}' do
    operation :post do
      key :summary, 'Follow a user'
      key :operationId, 'follow_user'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Follow'
      ]
      parameter do
        key :in, :path
        key :name, :user_id
        key :description, 'UUID of the user to follow.'
        key :required, true
        key :type, :string
      end
    end

    operation :delete do
      key :summary, 'Unfollow a user'
      key :operationId, 'unfollow_user'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Follow'
      ]
      parameter do
        key :in, :path
        key :name, :user_id
        key :description, 'UUID of the user to unfollow.'
        key :required, true
        key :type, :string
      end
    end
  end
end

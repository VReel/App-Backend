class FollowDoc
  include Swagger::Blocks

  swagger_path '/follow/{userId}' do
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
        key :name, :userId
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
        key :name, :userId
        key :description, 'UUID of the user to unfollow.'
        key :required, true
        key :type, :string
      end
    end
  end

  swagger_path '/followers' do
    operation :get do
      key :summary, 'Get a list of your followers'
      key :operationId, 'followers'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Follow'
      ]
      parameter do
        key :in, :query
        key :name, :page
        key :description, 'Gets next page of followers.'
        key :required, false
        key :type, :string
      end
    end
  end

  swagger_path '/following' do
    operation :get do
      key :summary, 'Get a list of users you follow'
      key :operationId, 'following'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Follow'
      ]
      parameter do
        key :in, :query
        key :name, :page
        key :description, 'Gets next page of users you follow.'
        key :required, false
        key :type, :string
      end
    end
  end
end

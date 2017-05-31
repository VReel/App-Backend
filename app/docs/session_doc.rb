class SessionDoc
  include Swagger::Blocks

  swagger_path '/users/sign_in' do
    operation :post do
      security do
        key 'vreel-application-id', []
      end
      key :summary, 'Sign in'
      key :description, 'Creates a new session. Login should be handle or email'
      key :operationId, 'sign_in'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Session'
      ]
      parameter do
        key :in, :body
        key :name, :body
        key :description, 'User credentials'
        key :required, true
        schema do
          key :'$ref', :AuthInput
        end
      end
    end
  end

  swagger_path '/users/sign_out' do
    operation :delete do
      key :summary, 'Sign out'
      key :operationId, 'sign_out'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Session'
      ]
    end
  end

  swagger_schema :AuthInput do
    allOf do
      schema do
        key :required, [:login, :password]
        property :login do
          key :type, :string
        end
        property :password do
          key :type, :string
        end
        property :player_id do
          key :type, :string
        end
      end
    end
  end
end

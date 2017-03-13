class UserDoc
  include Swagger::Blocks

  swagger_schema :User do
    key :required, [:id, :handle, :email]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :handle do
      key :type, :string
    end
    property :email do
      key :type, :string
    end
  end

  swagger_path '/users' do
    operation :post do
      security nil
      key :summary, 'Create new user'
      key :operationId, 'register'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Registration'
      ]
      parameter do
        key :in, :body
        key :name, :body
        key :description, 'User object to be created'
        key :required, true
        schema do
          key :'$ref', :UserInput
        end
      end
    end

    operation :put do
      key :summary, 'Update a user'
      key :description, 'If the password is to be updated, then all of password, password_confirmation
        and current_password must be present. Other fields can be updated without dependencies'
      key :operationId, 'delete_user'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Registration'
      ]
      parameter do
        key :in, :body
        key :name, :body
        key :description, 'User object to be updated'
        key :required, true
        schema do
          key :'$ref', :UserUpdateInput
        end
      end
    end

    operation :delete do
      key :summary, 'Delete a user'
      key :operationId, 'delete_user'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Registration'
      ]
    end
  end

  swagger_schema :UserInput do
    allOf do
      schema do
        key :required, [:handle, :email, :password, :password_confirmation]
        property :handle do
          key :type, :string
        end
        property :email do
          key :type, :string
        end
        property :password do
          key :type, :string
        end
        property :password_confirmation do
          key :type, :string
        end
      end
    end
  end

  swagger_schema :UserUpdateInput do
    allOf do
      schema do
        property :handle do
          key :type, :string
        end
        property :email do
          key :type, :string
        end
        property :password do
          key :type, :string
        end
        property :password_confirmation do
          key :type, :string
        end
        property :current_password do
          key :type, :string
        end
      end
    end
  end
end

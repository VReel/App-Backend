class PasswordDoc
  include Swagger::Blocks

  swagger_path '/users/password' do
    operation :post do
      security do
        key 'vreel-application-id', []
      end
      key :summary, 'Request a password reset'
      key :operationId, 'request_password_reset'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Passwords'
      ]
      parameter do
        key :in, :body
        key :name, :body
        key :description, 'User email'
        key :required, true
        schema do
          key :'$ref', :RequestPasswordResetInput
        end
      end
    end
  end

  swagger_schema :RequestPasswordResetInput do
    allOf do
      schema do
        key :required, [:email]
        property :email do
          key :type, :string
        end
      end
    end
  end
end

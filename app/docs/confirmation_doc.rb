class ConfirmationDoc
  include Swagger::Blocks

  swagger_path '/users/confirmation' do
    operation :post do
      security do
        key 'vreel-application-id', []
      end
      key :summary, 'Request a new confirmation email'
      key :operationId, 'request_confirmation'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Confirmations'
      ]
      parameter do
        key :in, :body
        key :name, :body
        key :description, 'User email'
        key :required, true
        schema do
          key :'$ref', :RequestConfirmInput
        end
      end
    end
  end

  swagger_schema :RequestConfirmInput do
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

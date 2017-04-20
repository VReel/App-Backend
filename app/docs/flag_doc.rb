class FlagDoc
  include Swagger::Blocks

  swagger_schema :Flag do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :reason do
      key :type, :string
    end
  end

  swagger_path '/posts/{postId}/flags' do
    operation :post do
      key :summary, 'Flag a post'
      key :operationId, 'create_flag'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Flag'
      ]
      parameter do
        key :name, :postId
        key :in, :path
        key :description, 'ID of post to flag'
        key :required, true
        key :type, :string
      end
      parameter do
        key :in, :body
        key :name, :body
        key :description, 'Flag object to be created'
        key :required, true
        schema do
          key :'$ref', :FlagInput
        end
      end
    end
  end

  swagger_schema :FlagInput do
    allOf do
      schema do
        property :reason do
          key :type, :string
        end
      end
    end
  end
end

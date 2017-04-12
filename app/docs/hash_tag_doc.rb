class HashTagDoc
  include Swagger::Blocks

  swagger_path '/hash_tags/{hashTag}' do
    operation :get do
      key :summary, 'Get a hash tag'
      key :operationId, 'get_hash_tag'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Hash Tag'
      ]
      parameter do
        key :in, :path
        key :name, :hashTag
        key :description, 'Hash tag (prefixed with #) or hash tag uuid to get'
        key :required, true
        key :type, :string
      end
    end
  end
end

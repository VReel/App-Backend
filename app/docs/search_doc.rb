class SearchDoc
  include Swagger::Blocks

  swagger_path '/search/users/{term}' do
    operation :get do
      key :summary, 'Search for users by name'
      key :description, 'Typically used for autocompletion'
      key :operationId, 'search_users'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Search', 'User'
      ]
      parameter do
        key :in, :path
        key :name, :term
        key :description, 'Search term to search for'
        key :required, true
        key :type, :string
      end
    end
  end

  swagger_path '/search/hash_tags/{term}' do
    operation :get do
      key :summary, 'Search for hash_tags by name'
      key :description, 'Typically used for autocompletion'
      key :operationId, 'search_hash_tags'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Search', 'Hash Tag'
      ]
      parameter do
        key :in, :path
        key :name, :term
        key :description, 'Search term to search for'
        key :required, true
        key :type, :string
      end
    end
  end
end

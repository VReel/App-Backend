class TimelineDoc
  include Swagger::Blocks

  swagger_path '/timeline' do
    operation :get do
      key :summary, 'Get timeline of posts by the users followed by the current user'
      key :operationId, 'timeline'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Timeline'
      ]
      parameter do
        key :in, :query
        key :name, :page
        key :description, 'Gets next page of posts.'
        key :required, false
        key :type, :string
      end
    end
  end

  swagger_path '/public_timeline' do
    operation :get do
      key :summary, 'Get timeline of all posts in system'
      key :operationId, 'public_timeline'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Timeline'
      ]
      parameter do
        key :in, :query
        key :name, :page
        key :description, 'Gets next page of posts.'
        key :required, false
        key :type, :string
      end
    end
  end
end

class StatsDoc
  include Swagger::Blocks

  swagger_path '/stats' do
    operation :get do
      key :summary, 'Get summary system stats'
      key :description, 'Authorized chiefs only'
      key :operationId, 'stats'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Stats'
      ]
      parameter do
        key :in, :query
        key :name, :date_from
        key :description, 'Start date for query. Any sensible time format but ISO8601 is good.'
        key :required, false
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :date_to
        key :description, 'End date for query. Any sensible time format but ISO8601 is good.'
        key :required, false
        key :type, :string
      end
    end
  end
end

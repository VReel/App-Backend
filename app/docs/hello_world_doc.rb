class HelloWorldDoc
  include Swagger::Blocks

  swagger_path '/' do
    operation :get do
      key :summary, 'Get a hello world message'
      key :description, 'Authorized users only'
      key :operationId, 'hello_world'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Hello world'
      ]
    end
  end
end

require 'swagger/blocks'

class ApidocsController < ActionController::Base
  protect_from_forgery with: :exception
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    security do
      key :client, []
      key 'access-token', []
      key :uid, []
      key 'vreel-application-id', []
    end
    security_definition 'vreel-application-id' do
      key :type, 'apiKey'
      key :name, 'vreel-application-id'
      key :in, 'header'
    end
    security_definition :client do
      key :type, 'apiKey'
      key :name, 'client'
      key :in, 'header'
    end
    security_definition 'access-token' do
      key :type, 'apiKey'
      key :name, 'access-token'
      key :in, 'header'
    end
    security_definition 'uid' do
      key :type, 'apiKey'
      key :name, 'uid'
      key :in, 'header'
    end
    info do
      key :version, '1.0.0'
      key :title, 'VReel API'
      key :description, "User authentication based on https://github.com/lynndylanhurley/devise_token_auth. <br>\
        Authenticated requests need 'client', 'access-token', and 'uid' passed in the headers of each request as\
        in https://tools.ietf.org/html/rfc6750. \
        <br>Response bodies follow the JSON API specification http://jsonapi.org/"
      key :termsOfService, '-'
      contact do
        key :name, 'dan@reasonfactory.com'
      end
    end
    tag do
      key :name, 'user'
      key :description, 'User operations'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://swagger.io'
      end
    end
    key :basePath, '/v1/'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    ErrorDoc,
    UserDoc,
    ConfirmationDoc,
    PasswordDoc,
    SessionDoc,
    S3PresignedUrl,
    PostDoc,
    FollowDoc,
    SearchDoc,
    StatsDoc,
    HelloWorldDoc,
    self
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES).merge(
      host: Rails.env.development? ? "#{request.host}:#{request.port}" : request.host
    )
  end
end

class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :handle
end

class UserSerializer < ActiveModel::Serializer
  attributes :id, :handle, :name, :profile
end

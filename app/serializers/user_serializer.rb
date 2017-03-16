class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :handle, :name, :profile
end

Fabricator(:user_with_device, from: :user) do
  devices(count: 1)
end

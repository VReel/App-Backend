Fabricator(:user) do
  email { Faker::Internet.email }
  handle { Faker::Internet.user_name(nil, %w(_)) }
  password 'password'
  password_confirmation 'password'
end

Fabricator(:user) do
  email { Faker::Internet.email }
  handle { (Faker::Internet.user_name(nil, %w(_)) * 2).first(10) + rand(99).to_s }
  name { Faker::Name.name }
  password 'password'
  password_confirmation 'password'
end

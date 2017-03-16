Fabricator(:user) do
  email { Faker::Internet.email }
  handle { (Faker::Internet.user_name(nil, %w(_)) * 2).first(10)  }
  password 'password'
  password_confirmation 'password'
end

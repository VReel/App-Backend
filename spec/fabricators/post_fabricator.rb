Fabricator(:post) do
  thumbnail_key { Faker::File.file_name(SecureRandom.random_number(36**12).to_s(36)) }
  original_key { Faker::File.file_name(SecureRandom.random_number(36**12).to_s(36)) }
  caption { Faker::HarryPotter.quote }
end

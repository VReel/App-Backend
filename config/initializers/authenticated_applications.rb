begin
  if Rails.env.test?
    AUTHORIZED_APPLICATION_IDS = [ClientApplication.create(name: Faker::Name.name).application_id]
  else
    AUTHORIZED_APPLICATION_IDS = ClientApplication.all.map(&:application_id)
  end
rescue StandardError => e
  puts e.message
end

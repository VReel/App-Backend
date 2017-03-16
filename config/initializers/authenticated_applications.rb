if Rails.env.test?
  AUTHORIZED_APPLICATION_IDS = [ClientApplication.create(name: Faker::Name.name).application_id]
else
  begin
    AUTHORIZED_APPLICATION_IDS = ClientApplication.all.map(&:application_id)
  rescue StandardError => e
    puts e.message
  end
end

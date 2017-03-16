if Rails.env.test?
  AUTHORIZED_APPLICATION_IDS = [ClientApplication.create(name: Faker::Name.name).application_id]
else
  begin
    AUTHORIZED_APPLICATION_IDS = ClientApplication.all.map(&:application_id)
  rescue ActiveRecord => e
    puts e.message
  end
end

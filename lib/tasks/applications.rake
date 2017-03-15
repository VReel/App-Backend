namespace :applications do
  desc 'Create a new authorised application'
  task create: :environment do
    name = ENV['name']

    if name.blank?
      puts "Please supply a name - e.g. rake application:create name='new application name'"
    else
      application = ClientApplication.create(name: name)
      if application.persisted?
        puts "'#{name}' created. application_id: #{application.application_id}"
      else
        puts application.errors.inspect
      end
    end
  end

  desc 'Revoke access to an authorised application'
  task revoke: :environment do
    name = ENV['name']
    application_id = ENV['application_id']

    if name.blank? && application_id.blank?
      puts "Please supply a name or application_id - e.g. rake application:revoke name='application name'"
      exit
    else
      conditions = {}
      conditions['name'] = name if name.present?
      conditions['application_id'] = application_id if application_id.present?

      application = ClientApplication.where(conditions).first

      if application.present?
        application.destroy
        puts "Revoked access and destroyed #{application.name} #{application.application_id}"
      else
        puts 'Application not found.'
      end
    end
  end

  desc 'List allowed applications'
  task list: :environment do
    applications = ClientApplication.all

    if applications.empty?
      puts 'No applications found'
    else
      puts 'name' + (' ' * 15) + '| application_id ' + ' ' * 50 + '| created_at'
      puts '-' * 111
      applications.each do |application|
        puts application.name + (' ' * (19 - application.name.size)) + '| ' +
             application.application_id + ' | ' + application.created_at.to_s
      end
    end
  end
end

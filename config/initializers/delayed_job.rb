Delayed::Worker.delay_jobs = false if Rails.env.test?
Delayed::Worker.max_attempts = 12
Delayed::Worker.sleep_delay = ENV['DELAYED_JOB_SLEEP_DELAY'] || 1
Delayed::Worker.destroy_failed_jobs = false

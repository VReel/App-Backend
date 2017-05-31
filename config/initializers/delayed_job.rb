Delayed::Worker.delay_jobs = false if Rails.env.test?
Delayed::Worker.max_attempts = 5
Delayed::Worker.sleep_delay = ENV['DELAYED_JOB_SLEEP_DELAY'] || 1
Delayed::Worker.destroy_failed_jobs = false

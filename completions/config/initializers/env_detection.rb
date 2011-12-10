def development_environment?
  ENV['RAILS_ENV'] == 'development'
end

def test_environment?
  ENV['RAILS_ENV'] == 'test' || ENV['RAILS_ENV'] == 'cucumber'
end

def staging_environment?
  ENV['RAILS_ENV'] == 'staging'
end
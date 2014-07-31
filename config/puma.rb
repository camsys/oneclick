# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
workers Integer(ENV['PUMA_WORKERS'] || 3)
threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 1)

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # worker specific setup
  # ActiveSupport.on_load(:active_record) do
  #   ActiveRecord::Base.establish_connection
  # end

  if url = ENV['DATABASE_URL']
    ActiveRecord::Base.connection_pool.disconnect!
    parsed_url = URI.parse(url)
    config =  {
      adapter:             'postgis',
      host:                parsed_url.host,
      encoding:            'unicode',
      database:            parsed_url.path.split("/")[-1],
      port:                parsed_url.port,
      username:            parsed_url.user,
      password:            parsed_url.password
    }
    ActiveRecord::Base.establish_connection(config)
  end

end

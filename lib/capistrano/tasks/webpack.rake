namespace :load do
  task :defaults do
    set :sas_webpack_roles, %w[web]
    # set :sas_webpack_envvars, ''
    set :sas_webpack_dotenv_file, '.env'
  end
end

namespace :webpack do
  desc 'Run webpack'
  task :run do
    on roles(fetch(:sas_webpack_roles)) do |host|
      # webpack('--config', release_path.join('webpack.config.js'), "--env.RELEASE_PATH=\"#{release_path}\"")
      # webpack('--config', release_path.join('webpack.config.js'), fetch(:sas_webpack_envvars))
      webpack('--config', release_path.join('webpack.config.js'))
    end
  end

  def webpack(*args)
    webpack = fetch(:sas_webpack_path, release_path.join('node_modules', '.bin', 'webpack'))
    execute(webpack, *args)
    # env_cmd = fetch(:sas_env_cmd_path, release_path.join('node_modules', '.bin', 'env-cmd'))
    # execute(env_cmd, deploy_path.join(fetch(:sas_webpack_dotenv_file)), webpack, *args)
    # execute(*execute_dotenv_params, webpack, *args)
  end
end

after 'deploy:updated', 'webpack:run'


namespace :load do
  task :defaults do
    set :sas_python_roles, %w[all]
    set :sas_python_shared_virtualenv, false
    set :sas_python_virtualenv_name, 'virtualenv'
    set :sas_python_requirements_file, 'requirements.txt'
  end
end

namespace :python do
  desc 'Create a python virtualenv'
  task :create_virtualenv do
    on roles fetch(:sas_python_roles) do |host|
      execute("virtualenv -p python3 #{sas_python_virtualenv_path}")
      if fetch(:sas_python_shared_virtualenv)
        execute(:ln, '-s', sas_python_virtualenv_path, File.join(release_path, fetch(:sas_python_virtualenv_name)))
      end
    end
  end

  desc 'Install pip requirements'
  task :install_requirements do
    on roles fetch(:sas_python_roles) do |host|
      execute("#{sas_python_virtualenv_path}/bin/pip install -r #{release_path}/#{fetch(:sas_python_requirements_file)}")
    end
  end

  desc 'Add .env to activate script'
  task :update_environment_variables do
    on roles fetch(:sas_python_roles) do |host|
      # Source the .env file in the activate script (on line 3)
      execute("sed --in-place '3i source #{release_path}/.env' #{sas_python_virtualenv_path}/bin/activate")
      # Export the .env keys in the activate script (on line 4) (by splitting on = and getting the first field)
      execute("sed --in-place '4i export $(cut --delimiter== --fields=1 #{release_path}/.env)' #{sas_python_virtualenv_path}/bin/activate")
    end
  end

  # Defaults to a separate virtualenv per-deploy, but can be configured to create a virtualenv in the shared_path, and symlink it into the release path
  def sas_python_virtualenv_path
    (fetch(:sas_python_shared_virtualenv) ? shared_path : release_path).join(fetch(:sas_python_virtualenv_name))
  end
end

after 'deploy:updating', 'python:create_virtualenv'
after 'python:create_virtualenv', 'python:install_requirements'
after 'python:create_virtualenv', 'python:update_environment_variables'

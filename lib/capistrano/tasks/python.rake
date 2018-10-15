namespace :load do
  task :defaults do
    set :python_roles, %w[all]
    set :shared_virtualenv, false
    set :virtualenv_name, false
    set :requirements_file, 'requirements.txt'
  end
end

namespace :python do
  desc 'Create a python virtualenv'
  task :create_virtualenv do
    on roles fetch(:python_roles) do |host|
      execute "virtualenv -p python3 #{virtualenv_path}"
      if fetch(:shared_virtualenv)
        execute :ln, '-s', virtualenv_path, File.join(release_path, fetch(:virtualenv_name))
      end
    end
  end

  desc 'Install pip requirements'
  task :install_requirements do
    on roles fetch(:python_roles) do |host|
      execute "#{virtualenv_path}/bin/pip install -r #{release_path}/#{fetch(:requirements_file)}"
    end
  end

  # Defaults to a separate virtualenv per-deploy, but can be configured to create a virtualenv in the shared_path, and symlink it into the release path
  def virtualenv_path
    File.join(fetch(:shared_virtualenv) ? shared_path : release_path, fetch(:virtualenv_name))
  end
end

after 'deploy:updating', 'python:create_virtualenv'
after 'python:create_virtualenv', 'python:install_requirements'

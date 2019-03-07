namespace :load do
  task :defaults do
    set :sas_django_roles, %w[web]
  end
end

namespace :django do

  desc 'Collectstatic: Collects the static files into STATIC_ROOT'
  task :collectstatic do
    sas_django_manage('collectstatic', '--ignore *.coffee --ignore *.less --ignore node_modules/* --ignore bower_components/* --noinput --clear')
  end

  desc 'Migrate: synchronizes the database state with the current set of models and migrations'
  task :migrate do
    sas_django_manage('migrate', '--noinput')
  end

  desc 'Migrate: synchronizes the database state with the current set of models and migrations'
  task :test do
    on roles(fetch(:sas_django_roles)) do |host|
      execute(*execute_dotenv_params, 'env')
    end
  end
  # # OPTIONAL TASKS
  # desc 'Compile Messages: Compiles .po files created by makemessages to .mo files for use with the built-in gettext support.'
  # task :compilemessages do
  #   if fetch(:compilemessages)
  #     django('compilemessages')
  #   end
  # end

  # # THIRD PARTY TASKS
  # # https://github.com/django-compressor/django-compressor
  # desc 'Compress: processes, combines and minifies linked and inline Javascript or CSS in a Django template into cacheable static files'
  # task :compress do
  #   django('compress')
  # end

  # sources the .env file, runs python from virtualenv, and uses the django manage.py script
  def sas_django_manage(*args)
    virtualenv = fetch(:sas_django_virtualenv_path, release_path.join('virtualenv'))
    python = virtualenv.join('bin', 'python')
    manage = release_path.join('manage.py')
    on roles(fetch(:sas_django_roles)) do |host|
      execute(*execute_dotenv_params, python, manage, *args)
    end
  end
end

after 'deploy:updated', 'django:collectstatic'
after 'deploy:updated', 'django:migrate'


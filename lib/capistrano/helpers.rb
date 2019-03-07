# Sources a .env file within the deploy path, and exports the keys, so they can be passed to the execute command
# As the params are returned as an array, the splat operator must be used !
# e.g. execute(*execute_dotenv_params, 'env')
# Note: we first do an echo, to avoid command map issues with the bash source command
# https://github.com/capistrano/sshkit#the-command-map
def execute_dotenv_params(dotenv_path = '.env')
  # The .dot env file
  dotenv_file = deploy_path.join(dotenv_path)
  dotenv_keys = "$(cut --delimiter== --fields=1 #{dotenv_file})"
  ['echo', '.env', '&&', '.', dotenv_file, '&&', 'export', dotenv_keys, '&&']
end

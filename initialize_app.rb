require './matrix_app'
require 'yaml'
config = YAML.load_file('config.yaml')
app = MatrixApp.new(config["host"])
app.register(config["callback_url"], config["app_password"])

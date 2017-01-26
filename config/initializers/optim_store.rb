# Be sure to restart your server when you modify this file.

Rails.application.config.optim_store = YAML.load(
  File.open(
    Rails.root.join("config/optim_store.yml")
  )
)[Rails.env].symbolize_keys

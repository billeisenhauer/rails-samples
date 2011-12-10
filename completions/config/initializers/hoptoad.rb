HoptoadNotifier.configure do |config|
  config.api_key = AppConfig.hoptoad_api_key
  config.proxy_host = AppConfig.proxy_host if AppConfig.proxy_host
  config.proxy_port = AppConfig.proxy_port.to_i if AppConfig.proxy_port
end
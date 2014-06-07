HighVoltage.configure do |config|
  # Remove the directory pages from the URL path,
  # and serve up routes from the root of the domain path
  config.route_drawer = HighVoltage::RouteDrawers::Root
end
Obscenity.configure do |config|
  config.blacklist   = "#{Rails.root}/config/banned_words.yml"
  #config.whitelist   = ["safe", "word"]
  #config.replacement = :stars
end
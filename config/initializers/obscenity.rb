Obscenity.configure do |config|
  config.blacklist   = "#{Rails.root}/config/banned_words_r18.yml"
  config.blacklist_another = "#{Rails.root}/config/banned_words_cosplay.yml"
  #config.whitelist   = ["safe", "word"]
  #config.replacement = :stars
end
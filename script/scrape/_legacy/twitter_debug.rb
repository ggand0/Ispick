require "#{Rails.root}/script/scrape"
require "#{Rails.root}/script/scrape_twitter"

Scrape::Twitter.scrape()
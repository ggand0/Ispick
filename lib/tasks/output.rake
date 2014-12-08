# encoding: utf-8
require "#{Rails.root}/script/output_csv.rb"


namespace :output do
  # Image情報及びFavoredImageのcsvデータを出力
  desc "Output Image and Boards data"
  task :csv, :environment do
    puts 'output CSV...'
    OutputCSV.output_images()
    OutputCSV.output_fi()
  end

end

# encoding: utf-8
require "#{Rails.root}/script/output_csv.rb"

namespace :output do
  # Export csv data of specified Image and FavoredImage
  desc "Output Image and Boards data"
  task :csv, [:src]=> :environment  do |t,args|
    puts 'output CSV...'
    if args[:src]
      src=args[:src]
    else
      src="all"
    end
    OutputCSV.output_images(src)
    OutputCSV.output_fi(src)
  end

end

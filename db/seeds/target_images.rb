include ActionDispatch::TestProcess
require "#{Rails.root}/app/workers/image_feature"
#require "#{Rails.root}/app/workers/target_image_feature"

# Generate target_images
files = Dir["#{Rails.root}/spec/files/target_images/*"]
count = 0

files.each do |f|
  target_image = TargetImage.new(data: fixture_file_upload(f))
  begin
    if target_image.save
      Resque.enqueue(ImageFeature, 'TargetImage', target_image.id)
    else
      puts 'failed.'
    end
  rescue Exception => e
    puts e.inspect
  end
  puts 'Seeding target_images table : ' + (count+1).to_s + ' / ' + files.length.to_s
  count += 1
end

puts 'DONE!'
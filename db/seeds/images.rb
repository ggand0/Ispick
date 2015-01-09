include ActionDispatch::TestProcess
require "#{Rails.root}/app/workers/image_feature"

# Generate images
files = Dir["#{Rails.root}/spec/files/images/*"]
count = 0

files.each do |f|
  image = Image.new(title: 'seed data ' + count.to_s, data: fixture_file_upload(f), src_url: 'seeddata.com/'+count.to_s)
  begin
    if image.save
      Resque.enqueue(ImageFeature, 'Image', image.id)
    else
      puts 'failed.'
    end
  rescue Exception => e
    puts e
  end
  puts 'Seeding images table : ' + (count+1).to_s + ' / ' + files.length.to_s
  count += 1
end
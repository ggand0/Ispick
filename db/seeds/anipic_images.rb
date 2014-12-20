include ActionDispatch::TestProcess
require "#{Rails.root}/app/workers/image_feature"

# Generate images
files = Dir["/home/ispick/Projects/images/anipic_single_5000/*"]
limit=1000
start = 1000+2475
count = start

files.each_with_index do |f, c|
  #break if c >= limit
  if c <= start
    puts 'skipped.'
    next 
  end
  
  begin
    image = Image.new(title: 'seed data ' + count.to_s, data: fixture_file_upload(f), src_url: 'seeddata_anipic.com/'+count.to_s)
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
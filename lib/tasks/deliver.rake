require "#{Rails.root}/app/services/target_images_service"

namespace :deliver do
  desc "Deliver images to all users"
  task all: :environment do
    User.all.each do |user|
      Rake::Task['deliver:user'].invoke user.id
    end
  end

  desc "User.firstにdeliver"
  task :user, [:user_id] =>  :environment do |t, args|
    delivered = []
    user = User.find(args[:user_id])
    targets = user.target_images

    count = 0
    targets.each do |t|
      puts 'Processing ' + (count+1).to_s + ' / ' + targets.length.to_s
      service = TargetImagesService.new
      result = service.get_preferred_images(t)

      puts 'Got preferred images...'
      puts result[:images].count

      result[:images].each do |i|
        #delivered.push(DeliveredImage.create(data: i[:image].data, title: i[:image].title))
        if image = DeliveredImage.create(data: i[:image].data, title: i[:image].title, src_url: i[:image].src_url)
          user.delivered_images << image
        end
      end
      count += 1
    end

    puts 'DONE!'
  end
end
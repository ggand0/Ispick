require "#{Rails.root}/app/services/target_images_service"

namespace :deliver do
  # 1回の配信で、1ユーザーに対して配信する推薦イラストの数
  @MAX_DELIVER_NUM = 100

  desc "Deliver images to all users"
  task all: :environment do
    User.all.each do |user|
      Rake::Task['deliver:user'].invoke user.id
    end
  end

  desc "個々のユーザーにイラストを配信"
  task :user, [:user_id] =>  :environment do |t, args|

    t0 = Time.now
    count = 0
    delivered = []

    user = User.find(args[:user_id])
    count_all = user.target_images.length
    user.target_images.each do |t|
      # 推薦イラストを取得
      puts 'Processing ' + (count+1).to_s + ' / ' + count_all.to_s
      service = TargetImagesService.new
      result = service.get_preferred_images(t)
      puts 'Preferred images: ' + result[:images].count.to_s

      # 既に配信済みの画像である場合はskip
      puts 'User.delivered_images.count: ' + user.delivered_images.count.to_s
      result[:images].reject! { |x| user.delivered_images.any?{ |d| d.src_url == x[:image].src_url }}
      puts 'Unique images: ' + result[:images].count.to_s

      # 最大配信数に絞る（推薦度の高い順に残す）
      if result[:images].count > @MAX_DELIVER_NUM
        puts 'Removing excessed images...'
        #puts MAX_DELIVER_NUM
        puts result[:images].class
        result[:images] = result[:images].take @MAX_DELIVER_NUM
      end
      puts 'Final delivered images: ' + result[:images].count.to_s

      # User.delivered_imagesへ追加
      c=0
      result[:images].each do |i|
        im = i[:image]
        file = File.open(im.data.path)
        image = DeliveredImage.create(title: im.title, src_url: im.src_url)
        if image
          # file.close出来てもuser.delivered_imagesはclose出来ない
          # (userがglobalから参照される限りuser.delivered_images[i].dataも参照される)ので、
          # ファイルへの参照数がタスク終了するまで増加していくことに注意。
          # 開いているファイル数がulimitで設定されている数を超えると'Too many open files...'エラー
          image.data = file
          user.delivered_images << image# ここがcritical
          user.save
        end
        file.close

        c+=1
        puts '- Creating delivered_images:' + c.to_s + ' / ' + result[:images].count.to_s if c % 10 == 0
      end

      t.last_delivered_at = DateTime.now
      count += 1
    end

    t1 = Time.now
    puts 'Elapsed time: ' + (t1-t0).to_s
    puts 'DONE!'
  end
end
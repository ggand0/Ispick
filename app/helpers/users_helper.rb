module UsersHelper
  def get_clip_string(delivered_image)
    if delivered_image.favored_image_id
      'Clipped'
    else
      'Clip'
    end
  end

  def get_clip_string_styled(delivered_image)
    style = ''
    if delivered_image.favored_image_id
      style = 'style="color: #02C293;"'
    else
      style = 'style="color: #000;"'
    end
    '<span '+style+'>' + get_clip_string(delivered_image) + '</span>'
  end

  def get_total_size_favored(favored_images)
    total_size = 0
    favored_images.each do |n|
      if n.delivered_image_id # まだコピーされていない(生存中のDeliveredImageを参照している)
        image = DeliveredImage.find(n.delivered_image_id)
        total_size += image.data.size
      else                    # 既にコピーされている(ソース元のDeliveredImageは削除されている)
        total_size += n.data.size
      end
    end
    total_size
  end

  def test_menu_items
    Proc.new do |primary|
      primary.dom_class = "nav nav-tabs"
      primary.item :home, 'Home', home_users_path
      primary.item :key_1, 'Home', '#' do |sub_nav|
        sub_nav.item :key_1_1, 'Home', home_users_path
        sub_nav.item :key_1_2, 'Home', home_users_path
      end
    end
  end
  def date_menu_items
    Proc.new do |primary|
      primary.dom_class = "nav nav-tabs"
      primary.item :dates, 'Dates', '#' do |sub_nav|
        # 動的に日付メニューを追加する：user.created_atからtodayまで
        user_created = current_user.created_at.to_date
        today = Time.now.in_time_zone('Asia/Tokyo').to_date
        #sym = ['1'.to_sym,'1'.to_sym,'1'.to_sym,'1'.to_sym,'1'.to_sym]
        #[0,1,2,3,4].each do |n|
        #  sub_nav.item sym[n], "#{n}", home_users_path
        #end
        range = (user_created..today).map{ |date| { date: date, str: date.strftime("%b %d") } }
        range.each do |date|
          sub_nav.item date[:str].to_sym, date[:str], home_users_path(
            date: date[:date], y: date[:date].year, m: date[:date].month, d: date[:date].day)
        end
      end
    end

  end

end

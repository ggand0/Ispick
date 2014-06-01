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
  def get_enabled_html(enabled)
    '<strong>' + (enabled ? 'on' : 'off') + '</strong>'
  end
  def get_illust_html(image)
    return 'Illust: nil' if image.nil?
    "Illust: <span><strong>#{image.is_illust.to_s}</strong></span>".html_safe
  end
  def get_quality_html(image)
    return 'Quality: nil' if image.nil?
    "Quality: <span><strong>#{image.quality.to_s}</strong></span>".html_safe
  end

  # simple-navigation関連
  def get_menu_items
    main_menu_items + config_menu_items + debug_menu_items
  end

  def main_menu_items
    [
      { key: :image_list, name: 'Users Home', url: home_users_path },
      { key: :list_clip, name: 'クリップイラスト一覧', url: show_favored_images_users_path }
    ]
  end

  def config_menu_items
    [{ key: :config, name: '好みの設定', url: '#', options: { container_class: 'nav nav-tabs' }, items: [
        { key: :config_word, name: '登録ワード一覧', url: show_target_words_users_path },
        { key: :config_image, name: '登録イラスト一覧', url: show_target_images_users_path }
      ]
    }]
  end

  def debug_menu_items
    [{ key: :list, name: 'DEBUG', url: '#', options: { container_class: 'nav nav-tabs' }, items: [
        { key: :image_list, name: '抽出画像一覧', url: images_path },
        { key: :target_image_list, name: 'うpされた嗜好画像一覧', url: target_images_path },
        { key: :debug_illust_detection, name: 'イラスト判定のデバッグを行う', url: debug_illust_detection_users_path },
        { key: :top, name: 'トップページ', url: '/' },
      ]
    }]
  end

  # 日付系menu
  def get_date_submenu
    # 動的に日付メニューを追加する：oldest delivered_image.created_atからtodayまで
    today = Time.now.in_time_zone('Asia/Tokyo').to_date
    if current_user.delivered_images.empty?
      start = today
    else
      start = current_user.delivered_images.reorder('created_at ASC').first.created_at.to_date
    end
    array = []

    range = (start..today).map{ |date| { date: date, str: date.strftime("%b %d") } }
    range.each do |date|
      array.push({ key: date[:str].to_sym, name: date[:str], url:
        "/users/home/#{date[:date].year}/#{date[:date].strftime("%m")}/#{date[:date].strftime("%d")}" })
    end
    array
  end
  def date_menu_items
    [{ key: :date, name: 'Dates', url: '#', items: get_date_submenu
    }]
  end
end

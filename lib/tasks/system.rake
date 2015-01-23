# encoding: utf-8

namespace :system do
  desc "Update the daily ranking"
  task :update_ranking, :environment do
    limit = 100

    # Collect most viewed images and save them to ranking records.
    # Sort them in decending order
    tmp =
      Impression.where('created_at > (?)', DateTime.now.utc.to_date).
      group_by(&:impressionable_id).
      sort_by{|k,v| v.count}.
      reverse[0..limit-1]

    impressions = tmp.map {|k,v| k}
    puts tmp.map { |k,v| v.count }

    images = Image.where(id: impressions)
    images.each do |image|
      RankingImage.create!(image_id: image.id)
    end

    # Save the most viewed image as a DailyImage record
    puts images.first
    image = images.first
    DailyImage.create!(
      image_id: image.id,
      title: image.title,
      caption: image.caption,
      src_url: image.src_url,
      page_url: image.page_url,
      original_url: image.original_url,
      site_name: image.site_name,
      original_view_count: image.original_view_count,
      original_favorite_count: image.original_favorite_count,
      posted_at: image.posted_at,
      artist: image.artist,
      poster: image.poster,
      original_width: image.original_width,
      original_height: image.original_height,
      width: image.width,
      height: image.height
    )
  end
end
#-*- coding: utf-8 -*-
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

module Deliver
  def self.delete_excessed_records(images, max_size)
    delete_count = 0
    image_size = get_total_size(images)

    # 削除する数を計算（順に消してシミュレートしていく）
    images.order(:created_at).each do |i|
      image_size -= i.data.size
      delete_count += 1
      break if image_size <= max_size
    end

    # 古い順(created_atのASC)
    images.limit(delete_count).order(:created_at).destroy_all
    images
  end
end
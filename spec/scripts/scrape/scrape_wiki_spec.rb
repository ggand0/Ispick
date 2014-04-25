require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_wiki"
include Scrape::Wiki

describe "Scrape" do
  describe "save_to_database function" do
    let(:hash) {{
      FateSN: ['イリヤスフィール・フォン・アインツベルン（Illyasviel von Einzbern）'],
      Madoka: ['鹿目 まどか（かなめ まどか）']
    }}

    it "save valid values to database" do
      Scrape::Wiki.save_to_database(hash)
      # 今の所アニメタイトルしか保存していないため
      expect(Person.first.keywords.count).to eq(1)
    end
  end
end
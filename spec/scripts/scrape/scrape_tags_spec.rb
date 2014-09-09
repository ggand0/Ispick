require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape_tags"

describe Scrape::Tags do
  before do
    #IO.any_instance.stub(:puts)
  end

  describe "get_name_english method" do
    it "returns a valid name in english" do
      name_roman = 'Hatsune Miku'
      result = Scrape::Tags.get_name_english(name_roman)
      expect(result).to eq('Miku Hatsune')
    end

    it "returns the same string if it contains more than three words" do
      name_roman = 'Illyasviel von Einzbern'
      result = Scrape::Tags.get_name_english(name_roman)
      expect(result).to eq('Illyasviel von Einzbern')
    end
  end

end
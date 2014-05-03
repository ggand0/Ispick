require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the UsersHelper. For example:
#
# describe UsersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe UsersHelper do
  describe "get_clip_string method" do
    it "returns valid string" do
      image = FactoryGirl.create(:delivered_image)
      expect(helper.get_clip_string(image)).to eq('Clip')

      image = FactoryGirl.create(:favored_image_with_delivered)
      expect(helper.get_clip_string(image.delivered_image)).to eq('Clipped')
    end
  end

  describe "get_clip_string_styled" do
    it "returns valid string" do
      image = FactoryGirl.create(:delivered_image)
      expect(raw helper.get_clip_string_styled(image)).to eq('<span style="color: #000;">Clip</span>')

      image = FactoryGirl.create(:favored_image_with_delivered)
      expect(raw helper.get_clip_string_styled(image.delivered_image)).to eq(
        '<span style="color: #02C293;">Clipped</span>')
    end
  end
  describe "get_enabled_html" do
    it "returns valid html string" do
      target_word = FactoryGirl.create(:target_word)
      result = helper.get_enabled_html(target_word.enabled)
      expect(raw result).to eql('<strong>on</strong>')

      target_word.enabled = false
      result = helper.get_enabled_html(target_word.enabled)
      expect(raw result).to eql('<strong>off</strong>')
    end
  end
  describe "get_illust_html method" do
    it "returns valid html" do
      delivered_image = FactoryGirl.create(:delivered_image)
      result = helper.get_illust_html(delivered_image.image)
      #expect(result).to eql('Illust: <span style="color:#3598FF">true</span>')
      expect(result).to eql('Illust: <span>true</span>')
    end
  end

  # simple-navigation methods
  # タブの仕様が決まったら細かく書く：
  describe "simple-navigation methods" do
    before do
      user = FactoryGirl.create(:user_with_delivered_images)
      view.stub(:current_user).and_return(user)
    end

    describe "get_menu_items method" do
      it "returns an array contains valid items" do
        items = helper.get_menu_items
        expect(items).to be_an(Array)

        expect(items.count).to eql(2)
        expect(items.first[:key]).to eql(:date)
        expect(items.second[:key]).to eql(:list)
      end
    end

    describe "get_date_submenu method" do
      it "returns an array contains valid items" do
        items = helper.get_date_submenu

        expect(items).to be_an(Array)
        expect(items.count).to be > 0    # 最低限今日の日付はあるはず
      end

      # 配信画像が無い時は当日の日付リンクのみ
      it "returns only one item(that represent today) when current_user has no delivered_images" do
        user_with_no_delivered_images = FactoryGirl.create(:user)
        view.stub(:current_user).and_return(user_with_no_delivered_images)

        items = helper.get_date_submenu
        expect(items.count).to eql(1)
      end
    end

    describe "date_menu_items method" do
      it "returns an array object" do
        items = helper.date_menu_items

        expect(items).to be_an(Array)
        expect(items.count).to eql(1)
        expect(items.first[:key]).to eql(:date)
      end
    end

    describe "list_menu_items method" do
      it "returns an array contains valid items" do
        items = helper.list_menu_items

        expect(items).to be_an(Array)
        expect(items.count).to eql(1)
        expect(items.first[:key]).to eql(:list)
      end
    end
  end

end

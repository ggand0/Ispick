# -*- coding: utf-8 -*-
module Pixiv
  class TagSearchList < OwnedIllustList
    # (see super.url)
    def self.url(member_id, page = 1)
      "#{ROOT_URL}/bookmark_new_illust.php?p=#{page}"
    end

    # @return [Integer]
    lazy_attr_reader(:total_count) {
      node = at!('span[class="count-badge"]')
      node.inner_text[/\d+/].to_i
    }

    # @return [Array<Hash{Symbol=>Object}, nil>]
    lazy_attr_reader(:page_hashes) {
      search!('li[class="image-item"]').map {|n| hash_from_list_item(n) }
    }

    private

    # @param [Nokogiri::XML::Node] node
    # @return [Hash{Symbol=>Object}] illust_hash
    def hash_from_list_item(node)
      return nil if node.at('img[src*="limit_unknown_s.png"]')
      member_node = node.at('a[class^="user"]')
      illust_node = node.at('a')
      illust_id = illust_node['href'][/illust_id=(\d+)/, 1].to_i
      {
        url: Illust.url(illust_id),
        illust_id: illust_id,
        title: illust_node.at('h1').inner_text,
        member_id: member_node['href'][/\?id=(\d+)/, 1].to_i,
        member_name: member_node.inner_text,
        small_image_url: illust_node.at('img')['src'],
      }
    end
  end
end
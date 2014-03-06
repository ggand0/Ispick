require 'mechanize'
require 'uri'

module Pixiv
  autoload :BookmarkList,        'pixiv/bookmark_list'
  autoload :Client,              "#{Rails.root}/script/pixiv/client"#'pixiv/client'
  autoload :Error,               'pixiv/error'
  autoload :Illust,              "#{Rails.root}/script/pixiv/illust"#'pixiv/illust'
  autoload :IllustList,          'pixiv/illust_list'
  autoload :Member,              'pixiv/member'
  autoload :OwnedIllustList,     'pixiv/owned_illust_list'
  autoload :Page,                "#{Rails.root}/script/pixiv/page"#'pixiv/page'
  autoload :PageCollection,      'pixiv/page_collection'
  autoload :PrivateBookmarkList, 'pixiv/bookmark_list'
  autoload :SearchResultList,    'pixiv/search_result_list'
  autoload :WorkList,            'pixiv/work_list'

  ROOT_URL = 'http://www.pixiv.net'

  # @deprecated Use {.client} instead. Will be removed in 0.1.0.
  # Delegates to {Pixiv::Client#initialize}
  def self.new(*args, &block)
    Pixiv::Client.new(*args, &block)
  end

  # See {Pixiv::Client#initialize}
  # @return [Pixiv::Client]
  def self.client(*args, &block)
    Pixiv::Client.new(*args, &block)
  end
end

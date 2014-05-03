FactoryGirl.define do
  factory :tumblr_api_response, class: Hash do
    response {{
      'blog'=>{title: '宅男的reblog保管庫', name: 'realotakuman'},
      'posts'=>[{
        'blog_name'=>"realotakuman",
        'id'=>84103502875,
        'post_url'=>"http://realotakuman.tumblr.com/post/84103502875/twitter-kiya-si-http-t-co-mq1t",
        'slug'=>"twitter-kiya-si-http-t-co-mq1t",
        'type'=>'photo',
        'date'=>"2014-04-28 05:47:24 GMT",
        'timestamp'=>1398664044,
        'note_count'=>4,
        'source_url'=>"https://twitter.com/kiya_si/status/306760976504586240/photo/1",
        'source_title'=>"twitter.com",
        'caption'=>"<p><a href=\"https://twitter.com/kiya_si/status/306760976504586240/photo/1\" target=\"_blank\">Twitter / kiya_si: ねこむすめ。多分わがまま。 http://t.co/mQ1t &#8230;</a></p>",
        'photos'=>["original_size"=>{"width"=>1023, "height"=>724, "url"=>"http://24.media.tumblr.com/f0f1686cddaa366105e8808a62abafea/tumblr_n4q830Nw3d1qdwsovo1_1280.jpg"}]
      }]
    }}

    initialize_with { attributes }
  end
end
 #{}"photos"=>[{"caption"=>"", "alt_sizes"=>[{"width"=>1023, "height"=>724, "url"=>"http://24.media.tumblr.com/f0f1686cddaa366105e8808a62abafea/tumblr_n4q830Nw3d1qdwsovo1_1280.jpg"}, {"width"=>500, "height"=>354, "url"=>"http://37.media.tumblr.com/f0f1686cddaa366105e8808a62abafea/tumblr_n4q830Nw3d1qdwsovo1_500.jpg"}, {"width"=>400, "height"=>283, "url"=>"http://24.media.tumblr.com/f0f1686cddaa366105e8808a62abafea/tumblr_n4q830Nw3d1qdwsovo1_400.jpg"}, {"width"=>250, "height"=>177, "url"=>"http://31.media.tumblr.com/f0f1686cddaa366105e8808a62abafea/tumblr_n4q830Nw3d1qdwsovo1_250.jpg"}, {"width"=>100, "height"=>71, "url"=>"http://24.media.tumblr.com/f0f1686cddaa366105e8808a62abafea/tumblr_n4q830Nw3d1qdwsovo1_100.jpg"}, {"width"=>75, "height"=>75, "url"=>"http://24.media.tumblr.com/f0f1686cddaa366105e8808a62abafea/tumblr_n4q830Nw3d1qdwsovo1_75sq.jpg"}], }]}
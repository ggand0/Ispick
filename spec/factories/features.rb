FactoryGirl.define do
  factory :feature_test1, class: Feature do
    face '[{"zero value": 0}]'
    association :featurable, factory: :target_image
  end
  # 顔特徴量を検出出来なかった画像
  factory :feature_test2, class: Feature do
    face '[]'
    association :featurable, factory: :target_image
  end
  # まだ特徴抽出してない画像
  factory :feature_test3, class: Feature do
    face nil
    association :featurable, factory: :target_image
  end


  # For specs that handle single face:
  # A general target_image with face feature
  factory :feature_madoka, class: Feature do
    face  '[{"likelihood":0.9999814629554749,"face":{"x":501,"y":286,"width":286,"height":286},"skin_color":{"blue":231,"green":244,"red":249},"hair_color":{"blue":170,"green":206,"red":249},"eyes":{"left":{"x":646,"y":349,"width":95,"height":62,"colors":{"blue":122,"green":135,"red":187}},"right":{"x":511,"y":399,"width":67,"height":56,"colors":{"blue":106,"green":130,"red":190}}},"nose":{"x":599,"y":463},"chin":{"x":653,"y":549}}]'
    association :featurable, factory: :target_image
  end

  # feature_madokaに似た特徴量を持つ画像を仮定（hair_colorのrgb+10してる）
  factory :feature_madoka1, class: Feature do
    face  '[{"likelihood":0.9999814629554749,"face":{"x":501,"y":286,"width":286,"height":286},"skin_color":{"blue":231,"green":244,"red":249},"hair_color":{"blue":180,"green":216,"red":259},"eyes":{"left":{"x":646,"y":349,"width":95,"height":62,"colors":{"blue":122,"green":135,"red":187}},"right":{"x":511,"y":399,"width":67,"height":56,"colors":{"blue":106,"green":130,"red":190}}},"nose":{"x":599,"y":463},"chin":{"x":653,"y":549}}]'
    association :featurable, factory: :image
  end

  # feature_madokaに似てない特徴量を持つ画像を仮定（hair_colorのgb+-50してる）
  factory :feature_madoka2, class: Feature do
    face  '[{"likelihood":0.9999814629554749,"face":{"x":501,"y":286,"width":286,"height":286},"skin_color":{"blue":231,"green":244,"red":249},"hair_color":{"blue":170,"green":255,"red":199},"eyes":{"left":{"x":646,"y":349,"width":95,"height":62,"colors":{"blue":122,"green":135,"red":187}},"right":{"x":511,"y":399,"width":67,"height":56,"colors":{"blue":106,"green":130,"red":190}}},"nose":{"x":599,"y":463},"chin":{"x":653,"y":549}}]'
    association :featurable, factory: :image
  end


  # For specs that handle multiple faces:
  # madoka and homura
  factory :feature_madoka_homura, class: Feature do
    face '[{"likelihood":0.94766765832901,"face":{"x":666,"y":444,"width":592,"height":592},"skin_color":{"blue":200,"green":221,"red":238},"hair_color":{"blue":55,"green":52,"red":77},"eyes":{"left":{"x":1023,"y":592,"width":158,"height":120,"colors":{"blue":131,"green":97,"red":117}},"right":{"x":736,"y":652,"width":168,"height":120,"colors":{"blue":182,"green":172,"red":177}}},"nose":{"x":989,"y":793},"chin":{"x":991,"y":966}},{"likelihood":1.0,"face":{"x":1215,"y":324,"width":648,"height":648},"skin_color":{"blue":183,"green":225,"red":252},"hair_color":{"blue":166,"green":164,"red":237},"eyes":{"left":{"x":1615,"y":518,"width":186,"height":207,"colors":{"blue":131,"green":117,"red":149}},"right":{"x":1291,"y":455,"width":173,"height":190,"colors":{"blue":73,"green":94,"red":135}}},"nose":{"x":1487,"y":692},"chin":{"x":1450,"y":893}}]'
    association :featurable, factory: :target_image
  end

  # madoka0(madoka_homuraの特徴量に近い)
  factory :feature_madoka_anime, class: Feature do
    face ' [{"likelihood":0.9999865889549255,"face":{"x":51,"y":69,"width":139,"height":139},"skin_color":{"blue":208,"green":234,"red":253},"hair_color":{"blue":112,"green":79,"red":144},"eyes":{"left":{"x":142,"y":102,"width":37,"height":37,"colors":{"blue":52,"green":49,"red":105}},"right":{"x":65,"y":96,"width":43,"height":37,"colors":{"blue":36,"green":32,"red":91}}},"nose":{"x":115,"y":141},"chin":{"x":115,"y":184}}]'
    association :featurable, factory: :image
  end

  # homura0(madoka_homuraの特徴量に近い)
  factory :feature_homura_anime, class: Feature do
    face '[{"likelihood":1.0,"face":{"x":107,"y":143,"width":286,"height":286},"skin_color":{"blue":209,"green":236,"red":253},"hair_color":{"blue":84,"green":59,"red":77},"eyes":{"left":{"x":294,"y":230,"width":80,"height":75,"colors":{"blue":113,"green":119,"red":132}},"right":{"x":138,"y":234,"width":85,"height":73,"colors":{"blue":33,"green":44,"red":53}}},"nose":{"x":256,"y":318},"chin":{"x":252,"y":405}}]'
    association :featurable, factory: :image
  end


  factory :feature_image, class: 'Feature' do
    sequence(:face) { |r| '[{"likelihood":0.9999814629554749,"face":{"x":501,"y":286,"width":286,"height":286},"skin_color":{"blue":231,"green":244,"red":249},"hair_color":{"blue":170,"green":206,"red":' + "#{(r * 10) % 256}" +'},"eyes":{"left":{"x":646,"y":349,"width":95,"height":62,"colors":{"blue":122,"green":135,"red":187}},"right":{"x":511,"y":399,"width":67,"height":56,"colors":{"blue":106,"green":130,"red":190}}},"nose":{"x":599,"y":463},"chin":{"x":653,"y":549}}]' }
    association :featurable, factory: :image
  end
end
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
  factory :feature_madoka_multi, class: Feature do
    face '[{"likelihood":0.9942452311515808,"face":{"x":132,"y":56,"width":152,"height":152},"skin_color":{"blue":195,"green":224,"red":252},"hair_color":{"blue":155,"green":145,"red":247},"eyes":{"left":{"x":221,"y":95,"width":37,"height":39,"colors":{"blue":107,"green":102,"red":195}},"right":{"x":154,"y":97,"width":40,"height":38,"colors":{"blue":99,"green":104,"red":165}}},"nose":{"x":195,"y":141},"chin":{"x":201,"y":177}}]'
    association :featurable, factory: :image
  end

  # homura0(madoka_homuraの特徴量に近い)
  factory :feature_homura_multi, class: Feature do
    face '[{"likelihood":0.9999999403953552,"face":{"x":122,"y":183,"width":61,"height":61},"skin_color":{"blue":217,"green":225,"red":244},"hair_color":{"blue":98,"green":91,"red":116},"eyes":{"left":{"x":160,"y":193,"width":19,"height":14,"colors":{"blue":41,"green":38,"red":68}},"right":{"x":126,"y":195,"width":18,"height":14,"colors":{"blue":179,"green":155,"red":157}}},"nose":{"x":152,"y":215},"chin":{"x":152,"y":238}}]'
    association :featurable, factory: :image
  end


  factory :feature_image, class: 'Feature' do
    sequence(:face) { |r| '[{"likelihood":0.9999814629554749,"face":{"x":501,"y":286,"width":286,"height":286},"skin_color":{"blue":231,"green":244,"red":249},"hair_color":{"blue":170,"green":206,"red":' + "#{(r * 10) % 256}" +'},"eyes":{"left":{"x":646,"y":349,"width":95,"height":62,"colors":{"blue":122,"green":135,"red":187}},"right":{"x":511,"y":399,"width":67,"height":56,"colors":{"blue":106,"green":130,"red":190}}},"nose":{"x":599,"y":463},"chin":{"x":653,"y":549}}]' }
    association :featurable, factory: :image
  end

  factory :feature_target_delivered, class: Feature do
    # same as def madoka feature
    face  '[{"likelihood":0.9999814629554749,"face":{"x":501,"y":286,"width":286,"height":286},"skin_color":{"blue":231,"green":244,"red":249},"hair_color":{"blue":170,"green":206,"red":249},"eyes":{"left":{"x":646,"y":349,"width":95,"height":62,"colors":{"blue":122,"green":135,"red":187}},"right":{"x":511,"y":399,"width":67,"height":56,"colors":{"blue":106,"green":130,"red":190}}},"nose":{"x":599,"y":463},"chin":{"x":653,"y":549}}]'
    association :featurable, factory: :target_image_delivered
  end

  factory :feature_image_old, class: Feature do
    # same as def madoka feature
    face  '[{"likelihood":0.9999814629554749,"face":{"x":501,"y":286,"width":286,"height":286},"skin_color":{"blue":231,"green":244,"red":249},"hair_color":{"blue":170,"green":206,"red":249},"eyes":{"left":{"x":646,"y":349,"width":95,"height":62,"colors":{"blue":122,"green":135,"red":187}},"right":{"x":511,"y":399,"width":67,"height":56,"colors":{"blue":106,"green":130,"red":190}}},"nose":{"x":599,"y":463},"chin":{"x":653,"y":549}}]'
    association :featurable, factory: :image_old
  end

  factory :feature_image_new, class: Feature do
    # same as def madoka feature
    face  '[{"likelihood":0.9999814629554749,"face":{"x":501,"y":286,"width":286,"height":286},"skin_color":{"blue":231,"green":244,"red":249},"hair_color":{"blue":170,"green":206,"red":249},"eyes":{"left":{"x":646,"y":349,"width":95,"height":62,"colors":{"blue":122,"green":135,"red":187}},"right":{"x":511,"y":399,"width":67,"height":56,"colors":{"blue":106,"green":130,"red":190}}},"nose":{"x":599,"y":463},"chin":{"x":653,"y":549}}]'
    association :featurable, factory: :image_new
  end
end
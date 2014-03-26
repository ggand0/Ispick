json.array!(@target_words) do |target_word|
  json.extract! target_word, :id, :word
  json.url target_word_url(target_word, format: :json)
end

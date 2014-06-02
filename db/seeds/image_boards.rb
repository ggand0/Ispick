User.all.each do |user|
  user.image_boards << ImageBoard.create(name: 'Default')
end
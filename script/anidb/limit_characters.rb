# encoding: utf-8
# Limit tons of person records to main characters only

list_path = "#{Rails.root}/script/anidb/people_2014_main"
hash_path = "#{Rails.root}/script/anidb/characters_unmatched"
people = Person.all
hash = {}

match_count = 0
c = 0
File.open(list_path, "r") do |f|
  f.each_line do |line|
    puts line

    #puts line.class
    #puts line.encoding
    #puts Person.first.name.encoding

    line.gsub!("\n", '')
    hash[line] = false
    #puts true if line == 'イリヤスフィール・フォン・アインツベルン'
    #c += 1
    #break if c>= 7

    people.each_with_index do |person, count|
      #puts person.name if count==0
      #puts person.name.class if count==0
      #puts person.name if person.id == 4706


      if line.eql? person.name
        match_count+=1
        hash[line] = true
        puts person.name
      end
    end

  end
end

puts match_count
puts '###########Unmatched characters##############'
#hash = hash.map { |k,v| k if !v }
#puts hash.delete_if { |k, v| v.empty? }
puts hash.delete_if { |k, v| v or k.include? 'キュア' }
File.open(hash_path, 'w') do |f|
  hash.each do |key, value|
    f.write("#{key}: #{value}\n")
  end
end
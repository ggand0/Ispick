require 'fileutils'

=begin
def copy_with_path(src, dst)
  FileUtils.mkdir_p(File.dirname(dst))
  FileUtils.cp(src, dst)
end

file_path = "/Users/pentiumx/Projects/opencv_test/anime"
Image.all.each_with_index do |image, count|
  next if image.data.path.nil?
  copy_with_path(image.data.path, file_path)
  puts "#{count} images output"
end
=end
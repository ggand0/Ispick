module Paperclip
  class Custom < Thumbnail
    def initialize(file, options = {}, attachment = nil)
      super
      #@current_geometry.width  = target.crop_width
      #@current_geometry.height = target.crop_height

      @gif_first_frame_only = options.fetch(:gif_first_frame_only, false)
    end
    def target
      @attachment.instance
    end
    def transformation_command
=begin
      crop_command = [
        "-crop",
        "#{target.crop_width}x" \
          "#{target.crop_height}+" \
          "#{target.crop_x}+" \
          "#{target.crop_y}",
        "+repage"
      ]
=end
      crop_command = []
      puts @gif_first_frame_only
      if @animated #and @gif_first_frame_only
        # Remove all frames but the first frame
        crop_command = [
          "-delete",
          "1--1"
        ]
      end
      crop_command + super

    end
  end
end
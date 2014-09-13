module Paperclip
  class ManualCropper < Thumbnail
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
      if @gif_first_frame_only
        crop_command = [
          "-delete",
          "1--1"
        ]
      end
      crop_command + super

    end
  end
end
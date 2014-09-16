module Paperclip
  class Custom < Thumbnail
    def initialize(file, options = {}, attachment = nil)
      super
      @gif_first_frame_only = options.fetch(:gif_first_frame_only, false)
    end
    def target
      @attachment.instance
    end
    def transformation_command
      crop_command = []
      if @animated and @gif_first_frame_only
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
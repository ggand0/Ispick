module TargetImagesHelper
  require 'kaminari/helpers/paginator'
  def paginate_zero(array)
    if not array.count == 0
      paginate array
    else
      'No matches.'
    end
  end

  def paginate_target_images(message, array)
    if not message == ''
      message
    else
      paginate_zero(array)
    end
  end
end

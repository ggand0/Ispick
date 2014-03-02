module TargetImagesHelper
  require 'kaminari/helpers/paginator'
  def paginate_zero(array)
    if not array.count == 0
      paginate array
    else
      'No matches.'
    end
  end
end

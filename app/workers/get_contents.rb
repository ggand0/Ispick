#-*- coding: utf-8 -*-
class GetContents
  # Woeker起動時に指定するQUEUE名
  @queue = :get_contents

  def self.perform(module_name, *args)
    image = Object::const_get(module_name).get_contents(*args)

    puts 'GET_CONTENTS DONE!'
  end
end
class ImageFeature
  extend Resque::Plugins::Logger
  @queue = :image_feature

  def self.deploy_prototxt(image, temp_dir_path, mean_file_path)
    imagelist_path = Image.create_listfile(Image.find(image.id))

    # Copy the template to tmp directory
    #file_name = 'imagenet_features_template.prototxt'
    #template_path = "#{Rails.root}/script/caffe/#{file_name}"
    template_path = "#{CONFIG['template_path']}"
    FileUtils.cp(template_path, temp_dir_path)

    # Replace config strings
    text = File.read(File.join(temp_dir_path, template_path))
    #new_contents = text.gsub(/search_regexp/, "replacement string")
    new_config = text.gsub(/source: \"imagelist_file\"/, "source: \"#{imagelist_path}\"")
    new_config = new_config.gsub(/mean_file: \"images_mean.binaryproto\"/, "mean_file: \"#{mean_file_path}\"")
    File.open(file_name, "w") {|file| file.puts new_config }

    file_name
  end

  def self.exec_script(image)
    # .caffemodel file
    #pretrained_file = 'caffenet_train_iter_20000.caffemodel'
    #pretrained_path = "#{CONFIG['caffe_path']}/models/ispick/#{pretrained_file}"
    pretrained_path = "#{CONFIG['pretrained_path']}"
    # .npy file converted from .binaryproto file which was used for training
    #mean_file_path = "#{CONFIG['caffe_path']}/data/ispick/anipic_singles_mean.npy"
    mean_file_path = "#{CONFIG['mean_file_path']}"
    #model_file_path = "#{Rails.root}/script/caffe/imagenet_features_template.prototxt"
    model_file_path = "#{CONFIG['model_file_path']}"

    #Dir.mktmpdir do |temp_dir_path|
    # Memo: feature extraction with C++ (WIP)
    #tool_exec = "./build/tools/extract_features.bin models/ispick/caffenet_train_pmmm350_iter_2000.caffemodel features/imagenet_val.prototxt fc7 #{temp_dir_path} 1"
    #result = %x('cd' #{CONFIG['caffe_path']}; #{tool_exec})

    # Configure prototxt file
    #model_file_path = self.deploy_prototxt(image, temp_dir_path, mean_file_path
    # Execute the script and extract feature vectors
    dump_exec = "python #{CONFIG['caffe_path']}/extract_features.py #{mean_file_path} #{model_file_path} #{pretrained_path} #{image.data.path}"
    result = %x('cd' #{CONFIG['caffe_path']}; #{dump_exec})

    result
  end


  # @param [Image/TargetImage] A record of TargetImage model which has already saved.
  # @return [Hash] ImageNet categories included.
  def self.extract_features(image)
    result = self.exec_script(image)
    features = result[0..-2].split(' ')

    #hash = {}
    #(0..4095).each do |key|
    #  hash[key.to_s] = features[key].to_f
    #end

    { 'features' => features }
  end

  def self.perform(image_type, image_id)
    image = Object::const_get(image_type).find(image_id)
    logger.info json_string = self.extract_features(image).to_json
    puts json_string

    feature = Feature.new(convnet_feature: json_string)
    image.feature = feature

    logger.info 'IMAGE : FEATURE EXTRACTION DONE!'
  end
end

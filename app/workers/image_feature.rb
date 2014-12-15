class ImageFeature
  extend Resque::Plugins::Logger
  @queue = :image_feature

  def self.deploy_prototxt(image, temp_dir_path, mean_file_path)
    imagelist_path = Image.create_listfile(Image.find(image.id))

    # Copy the template to tmp directory
    file_name = 'imagenet_features_template.prototxt'
    template_path = "#{Rails.root}/script/caffe/#{file_name}"
    FileUtils.cp(template_path, temp_dir_path)

    # Replace config strings
    text = File.read(File.join(temp_dir_path, template_path))
    #new_contents = text.gsub(/search_regexp/, "replacement string")
    new_config = text.gsub(/source: \"imagelist_file\"/, "source: \"#{imagelist_path}\"")
    new_config = new_config.gsub(/mean_file: \"images_mean.binaryproto\"/, "mean_file: \"#{mean_file_path}\"")
    File.open(file_name, "w") {|file| file.puts new_config }

    file_name
  end


  # @param [Image/TargetImage] A record of TargetImage model which has already saved.
  # @return [Hash] ImageNet categories included.
  def self.extract_features(image)
    #model_path = ""       # .prototxt file for feature extraction
    pretrained_file = "caffenet_train_pmmm350_iter_6000.caffemodel"
    pretrained_path = "#{CONFIG['caffe_path']}/models/Ispick/#{pretrained_file}"  # .caffemodel file
    mean_file_path = "#{CONFIG['caffe_path']}/data/Ispick/pmmm350_mean.npy"                           # .npy file converted from .binaryproto file which was used for training
    #script_path = "/home/"      # Path of feature_extraction.py

    Dir.mktmpdir do |temp_dir_path|
      # Memo: feature extraction with C++ (WIP)
      #tool_exec = "./build/tools/extract_features.bin models/ispick/caffenet_train_pmmm350_iter_2000.caffemodel features/imagenet_val.prototxt fc7 #{temp_dir_path} 1"
      #result = %x('cd' #{CONFIG['caffe_path']}; #{tool_exec})

      # Configure prototxt file
      model_file_path = self.deploy_prototxt(image, temp_dir_path, mean_file_path)

      # Execute the script and extract feature vectors
      dump_exec = "python #{CONFIG['caffe_path']}/extract_features.py #{mean_file_path} #{model_file_path} #{pretrained_path}"
      result = %x('cd' #{CONFIG['caffe_path']}; #{dump_exec})
      arr = result[0..-2].split(',')
    end
    
=begin
    hash = {}
    result.split("\n").each do |line|
      tmp = line.split(',')
      hash[tmp[1]] = tmp[0].to_f
    end

    (0..4095).each do |key|
      hash[key.to_s] = 0 if not hash.has_key?(key.to_s)
    end
    hash.delete(nil)
=end

    hash
  end

  def self.perform(image_type, image_id)
    image = Object::const_get(image_type).find(image_id)
    logger.info json_string = self.get_categories(image).to_json
    feature = Feature.new(categ_imagenet: json_string)

    Feature.transaction do
      feature.save!
      Image.transaction do
        image.feature = feature
      end
    end

    logger.info 'IMAGE : FEATURE EXTRACTION DONE!'
  end
end

# encoding: utf-8
require "#{Rails.root}/script/restore_target_words"

namespace :util do
  desc "csvからTargetWordをrestore"
  task :target_words, [:csv_path] => :environment do |t, args|
    Util.restore_target_words(args.csv_path)
  end
end
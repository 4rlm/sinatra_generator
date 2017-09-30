require 'active_support/all'
require 'fileutils'
require 'pry'

module FileMigrator
  extend ActiveSupport::Concern

  puts "hi!"

  #  zip_out/to/filename/
  # ./zip_out/to/filename/
  #  FileUtils.mkdir_p("../#{@app_name}/app/controllers")
  # zip_out/to/filename/


  ### Trial ###
  # def self.unzip_files
  #   puts "I'm unzipped!"
  #   # src = Dir["zip_out/zip_samp/*"]
  #   # dest = "zip_out/to/"
  #   # FileUtils.cp(src, dest)
  # end


  # ### Working well. ###
  # src = Dir["zip_out/zip_samp/*"]
  # dest = "zip_out/to/"
  # FileUtils.cp(src, dest)





#########################
=begin
  # specify files which should not be copied
  # dont_copy = ['jquery.languageTags.js']
  dont_copy = []


  puts "Copying files from FE to BE folder"

  from_dir = "./zip_out/from"
  to_dir = "./zip_out/to"

  contains = Dir.new(from_dir).entries

  def copy_with_path(src, dst)
    binding.pry
    FileUtils.mkdir_p(File.dirname(dst))
    FileUtils.cp(src, dst)
  end

  Dir[from_dir + "/**/*.{js,jpg,jpeg,gif,png,css}"].each do |old_dest|
  	new_dest = old_dest.gsub(from_dir, to_dir)

  	# puts new_dest
  	should_not_copy = dont_copy.any? { |s| new_dest.end_with?(s) }

  	if !should_not_copy
  		puts new_dest
  		copy_with_path(old_dest, new_dest);
  	end
  end
=end
end

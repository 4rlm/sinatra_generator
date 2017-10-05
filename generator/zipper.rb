require 'rubygems'
# require 'zip/zipfilesystem'
require 'zip'
require 'fileutils'
require 'pry'
# require 'find'

class Zipper

  # helper_path = "../#{@app_name}/app/helpers/#{snake_case}.rb"

  def self.zip_it

    # Zipper.zip_it('../yhg', '../cool.zip')
    # Zip::ZipFile.open('../zipfile.zip', Zip::ZipFile::CREATE) do |zip|
    #   zip.file.open('file1', 'w') { |f1| f1 << 'This is file 1.' }
    #   zip.dir.mkdir('subdirectory')
    #   zip.file.open('subdirectory/file2', 'w') { |f1| f1 << 'This is file 2.' }
    # end

  end


  # def self.zip_it(dir, zip_dir, remove_after = false)
  #   Zip::ZipFile.open(zip_dir, Zip::ZipFile::CREATE)do |zip|
  #    Find.find(dir) do |path|
  #      Find.prune if File.basename(path)[0] == ?.
  #      dest = /#{dir}\/(\w.*)/.match(path)
  #      # Skip files if they exists
  #      begin
  #        zip.add(dest[1],path) if dest
  #      rescue Zip::ZipEntryExistsError
  #      end
  #    end
  #   end
  #   FileUtils.rm_rf(dir) if remove_after




    # Zip::File.open("../yhg", Zip::File::CREATE) { |zip|
    #   zip.get_output_stream("first.txt") { |f| f.puts "Hello from ZipFile" }
    #   zip.mkdir("a_dir")
    # }


    # binding.pry
    # @app_name
    # helper_path = "../#{@app_name}/app/helpers/#{snake_case}.rb"


    # Zip::File.open("my.zip", Zip::File::CREATE) { |zipfile|
    #   zipfile.get_output_stream("first.txt") { |f| f.puts "Hello from ZipFile" }
    #   zipfile.mkdir("a_dir")
    # }

    # helper_path = "../#{@app_name}/app/helpers/#{snake_case}.rb"



    # Zip::ZipFile.open('zipfile.zip', Zip::ZipFile::CREATE) do |zip|
    #   zip.file.open('file1', 'w') { |f1| f1 << 'This is file 1.' }
    #   zip.dir.mkdir('subdirectory')
    #   zip.file.open('subdirectory/file2', 'w') { |f1| f1 << 'This is file 2.' }
    # end



    # Zip::File.open("../testing_123.txt", Zip::File::CREATE) do |zip|
    #   zip.get_output_stream("first.txt") { |f| f.puts "Hello from ZipFile" }
    #   zip.mkdir('subdirectory')
    # end



  # def zip(dir, zip_dir, remove_after = false)
  #   binding.pry
  #   Zip::ZipFile.open(zip_dir, Zip::ZipFile::CREATE)do |zipfile|
  #     Find.find(dir) do |path|
  #       Find.prune if File.basename(path)[0] == ?.
  #       dest = /#{dir}\/(\w.*)/.match(path)
  #       # Skip files if they exists
  #       begin
  #         zipfile.add(dest[1],path) if dest
  #       rescue Zip::ZipEntryExistsError
  #       end
  #     end
  #   end
  #   FileUtils.rm_rf(dir) if remove_after
  # end

end

# Zipper.zip_it('/home/user/directory', '/home/user/compressed.zip')
# zip_it(dir, zip_dir, remove_after = false)
Zipper.zip_it

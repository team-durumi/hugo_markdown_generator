#! /usr/bin/ruby
require 'yaml'
require 'json'
require 'pathname'
require 'fileutils'

puts "[JSON 2 YAML MARKDOWN]"
puts "[JSON 2 YAML MARKDOWN] Script ititiated."

unless File.exist?('markdown_options.yml')
  puts "[JSON 2 YAML MARKDOWN] markdown_options.yml does not exist. Exiting the script."
  return false
end

options = YAML.load_file('markdown_options.yml')
unless !options.empty? && !options["base_directory"].nil?
  puts "[JSON 2 YAML MARKDOWN] Base directory specification required for the script to run. Exiting the script."
  return false
end
items_base_dir = File.expand_path(options["base_directory"])
unless File.directory?(items_base_dir)
  puts "[JSON 2 YAML MARKDOWN] Invalid directory #{items_base_dir}"
  return false
end

unless !options.empty? && !options["path_to_hugo_content"].nil?
  puts "[JSON 2 YAML MARKDOWN] Output path to hugo specification required for the script to run. Exiting the script."
  return false
end
output_dir = File.expand_path(options["path_to_hugo_content"])
unless File.directory?(output_dir)
  puts "[JSON 2 YAML MARKDOWN] Invalid directory #{output_dir}"
  return false
end

if !options.empty? && !options["hugo_content_directory_name"].nil?
  hugo_content_directory_name = options["hugo_content_directory_name"]
else
  hugo_content_directory_name = 'items'
  puts "[JSON 2 YAML MARKDOWN] Hugo contents directory will default to 'items' since you did not specify 'hugo_content_directory_name'."
end

unless File.directory?(items_base_dir)
  puts "[JSON 2 YAML MARKDOWN] Invalid directory. Exiting the script."
  return false
end

puts
puts "[JSON 2 YAML MARKDOWN] This script will fetch json files from #{items_base_dir} and convert it to yaml.md and place it under #{output_dir}/#{hugo_content_directory_name} "

puts
puts "Press 'Y' to continue the script or anything else to abort."
x = gets.chomp.upcase.strip
puts "You entered: #{x}"
unless x == 'Y'
  puts "[JSON 2 YAML MARKDOWN] Aborting the script as you wish."
  return false
end
puts "[JSON 2 YAML MARKDOWN] Proceeding with the script."
puts "[JSON 2 YAML MARKDOWN]"

puts "[JSON 2 YAML MARKDOWN] Proceeding with the script."
puts "[JSON 2 YAML MARKDOWN]"

puts "[JSON 2 YAML MARKDOWN] Inspecting directories under '#{items_base_dir}/'"
# valid_children = Dir.entries(items_base_dir).reject {|dir| %w{# .}.include? dir[0]} # trying to skip '#recycle' in synology nas 
# child_dirs = []
# valid_children.map {|dir| items_base_dir + '/' +  dir}.each {|path| child_dirs.push(Dir.glob(path + '/**/*/'))}
# child_dirs.flatten!
# child_dirs.reject! {|dir| dir.include? '@eaDir'} # trying to skip '@eaDir' in synology nas 
all_json_paths = Dir.glob("#{items_base_dir}/**/*.json")
puts "[JSON 2 YAML MARKDOWN] There are total #{all_json_paths.count} json files under '#{items_base_dir}'"
puts "[JSON 2 YAML MARKDOWN]"

all_json_paths.each do |path|
  puts "[JSON 2 YAML MARKDOWN] inspecting path #{path}"
  extension = File.extname(path)
  if File.file?(path) && File.extname(path) == '.json'
    md_file_path = (path.sub(items_base_dir, output_dir + '/' + hugo_content_directory_name)[0...-(extension.length)] + ".md")
    puts "[JSON 2 YAML MARKDOWN] Attempting to create markdown file at #{md_file_path}"
    enclosing_directory = Pathname(md_file_path).dirname
    FileUtils.mkdir_p enclosing_directory
    File.open(md_file_path, "w") do |f|
      f.write(YAML.dump(JSON.parse(File.read(path))))
      f << "---\n"
    end
    puts "[JSON 2 YAML MARKDOWN] successfully created file at #{md_file_path}"
  else
    puts "[JSON 2 YAML MARKDOWN] :::WARNING::: Check if json file exists at #{path}."
  end
end

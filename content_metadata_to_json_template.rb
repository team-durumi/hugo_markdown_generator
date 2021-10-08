#! /usr/bin/ruby
require 'yaml'
require 'json'

puts "[Hugo Contents Directories 2 JSON]"
puts "[Hugo Contents Directories 2 JSON] Script ititiated."

unless File.exist?('metameta.yml')
  puts "[Hugo Contents Directories 2 JSON] metameta.yml does not exist. Exiting the script."
  return false
end

options = YAML.load_file('metameta.yml')
unless !options.empty? && !options["base_directory"].nil?
  puts "[Hugo Contents Directories 2 JSON] Base directory specification required for the script to run. Please re-run the script with '-h' for help."
  return false
end

items_base_dir = File.expand_path(options["base_directory"])
unless File.directory?(items_base_dir)
  puts "[Hugo Contents Directories 2 JSON] Invalid directory. Exiting the script."
  return false
end

if options["remote_url"].nil?
  puts "[Hugo Contents Directories 2 JSON] You have not entered any remote_url for your content files. This means that your markdown file will include local file paths."
  # remote url 이 있으면 hugo_content_directory_name 이 무의미할듯.
  if options["hugo_content_directory_name"].nil?
    puts "[Hugo Contents Directories 2 JSON] You have not entered any hugo content directory name for your content files. This script will resort to default name as 'items'."
  else
    puts "[Hugo Contents Directories 2 JSON] You have entered \"#{options["hugo_content_directory_name"]}\" as the hugo content directory name for your files. This will be prepended to your file paths."
    puts "[Hugo Contents Directories 2 JSON] This automatically ignored any content_directory_name you might have put as options."
  end
else
  puts "[Hugo Contents Directories 2 JSON] You have entered \"#{options["remote_url"]}\" as the remote_url for your content files. This will be prepended to your file paths."
end

puts "[Hugo Contents Directories 2 JSON] Proceeding with the script."
puts "[Hugo Contents Directories 2 JSON]"

puts "[Hugo Contents Directories 2 JSON] Inspecting directories under '#{items_base_dir}/'"
# valid_children = Dir.entries(items_base_dir).reject {|dir| %w{# .}.include? dir[0]} # trying to skip '#recycle' in synology nas 
# child_dirs = []
# valid_children.map {|dir| items_base_dir + '/' +  dir}.each {|path| child_dirs.push(Dir.glob(path + '/**/*/'))}
# child_dirs.flatten!
# child_dirs.reject! {|dir| dir.include? '@eaDir'} # trying to skip '@eaDir' in synology nas 
all_children = Dir.glob("#{items_base_dir}/**/*")
puts "[Hugo Contents Directories 2 JSON] There are total #{all_children.count} directories and files under '#{items_base_dir}'"
puts "[Hugo Contents Directories 2 JSON]"

default_index_front_matters = %w{title weight type lastmod}
index_front_matters = (default_index_front_matters + options["front_matters"]["index"]).uniq
# index_hash_template = Hash[index_front_matters.map {|x| [x, nil]}]
default_single_front_matters = []
single_front_matters = (default_single_front_matters + options["front_matters"]["single"]).uniq
# single_hash_template = Hash[single_front_matters.map {|x| [x, nil]}]

all_children.each_with_index do |path, i|
  if File.directory?(path)
    # type = 'index'
    hash = Hash[index_front_matters.map {|x| [x, nil]}]

    directory_name = path.split('/').last
    hash["title"] = directory_name # if hash["title"]
    hash["type"] = 'page' # if hash["type"]
    # hash["weight"] = path.sub(items_base_dir, '').split('/').reject {|e| e.empty?}.count # if hash["weight"]
    hash["lastmod"] = File.mtime(path).strftime("%Y-%m-%d") # if hash["lastmod"]

    File.open(path + "/_index.json", "w") do |f|
      f.write(hash.to_json)
    end
  elsif File.file?(path)
    # type = 'single'
    hash = Hash[single_front_matters.map {|x| [x, nil]}]

    filename = File.basename(path).sub(File.extname(path), '')
    hash["title"] = filename # if hash["title"]

    hugo_content_directory_name = options["hugo_content_directory_name"].nil? ? 'items' : options["hugo_content_directory_name"]
    component_path = path.sub(items_base_dir, hugo_content_directory_name)
    remote_url = options["remote_url"].strip unless options["remote_url"].nil?
    unless remote_url.nil?
      component_path = component_path.sub(hugo_content_directory_name + '/', remote_url[-1] == '/' ? remote_url : remote_url + '/')
      component_path = component_path.gsub(' ', '+') if remote_url.include?('amazonaws')
    end
    # hash["title"] = "#{directory_name}-#{filename}"
    hash["title"] = filename
    hash["components"] = [].push(component_path)

    if File.extname(path) == '.pdf'
      puts
      puts "initiating tag process..."
      puts "converting pdf to txt"
      `ruby ./pdf2txt.rb "#{path}"`
      puts "attempting to get natto"
      require 'natto'
      text = File.read(path + ".txt")
      nm = Natto::MeCab.new
      result = nm.enum_parse(text)
      # puts result
      tag_array = []
      result.each do |part|
        if ['NNG', 'NNP'].include?(part.feature.split(',').first)
          tag_array.push(part.surface)    
        end
      end
      # puts tag_array
      keyword_frequency_desc = tag_array.each_with_object(Hash.new(0)){ |m,h| h[m] += 1 }.sort_by{ |k,v| v }.reverse
      tags = []
      # puts keyword_frequency_desc.first(5).map{|w| w[0] }
      hash["tags"] = keyword_frequency_desc.first(5).map{|w| w[0] }
      puts "done and cleaning up"
      File.delete(path + ".txt") if File.exists? (path + ".txt")
      puts "tag process done"
      puts
    end
      
    extension = File.extname(path)
    json_file_path = path[0...-(extension.length)] + ".json"
    File.open(json_file_path, "w") do |f|
      f.write(hash.to_json)
    end
  else
    puts "[Hugo Contents Directories 2 JSON] :::WARNING::: Check if #{path} is a valid path."
    next
  end
end

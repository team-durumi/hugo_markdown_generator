#! /usr/bin/ruby
require 'yaml'
require 'json'

puts "[Hugo Contents Directories 2 MARKDOWN]"
puts "[Hugo Contents Directories 2 MARKDOWN] Script ititiated."

unless File.exist?('metameta.yml')
  puts "[Hugo Contents Directories 2 MARKDOWN] metameta.yml does not exist. Exiting the script."
  return false
end

options = YAML.load_file('metameta.yml')
unless !options.empty? && !options["base_directory"].nil?
  puts "[Hugo Contents Directories 2 MARKDOWN] Base directory specification required for the script to run. Please re-run the script with '-h' for help."
  return false
end

items_base_dir = File.expand_path(options["base_directory"])
unless File.directory?(items_base_dir)
  puts "[Hugo Contents Directories 2 MARKDOWN] Invalid directory. Exiting the script."
  return false
end

if options["remote_url"].nil?
  puts "[Hugo Contents Directories 2 MARKDOWN] You have not entered any remote_url for your content files. This means that your markdown file will include local file paths."
  # remote url 이 있으면 hugo_content_directory_name 이 무의미할듯.
  if options["hugo_content_directory_name"].nil?
    puts "[Hugo Contents Directories 2 MARKDOWN] You have not entered any hugo content directory name for your content files. This script will resort to default name as 'items'."
  else
    puts "[Hugo Contents Directories 2 MARKDOWN] You have entered \"#{options["hugo_content_directory_name"]}\" as the hugo content directory name for your files. This will be prepended to your file paths."
    puts "[Hugo Contents Directories 2 MARKDOWN] This automatically ignored any content_directory_name you might have put as options."
  end
else
  puts "[Hugo Contents Directories 2 MARKDOWN] You have entered \"#{options["remote_url"]}\" as the remote_url for your content files. This will be prepended to your file paths."
end

puts "[Hugo Contents Directories 2 MARKDOWN] Proceeding with the script."
puts "[Hugo Contents Directories 2 MARKDOWN]"

puts "[Hugo Contents Directories 2 MARKDOWN] Inspecting directories under '#{items_base_dir}/'"
# valid_children = Dir.entries(items_base_dir).reject {|dir| %w{# .}.include? dir[0]} # trying to skip '#recycle' in synology nas 
# child_dirs = []
# valid_children.map {|dir| items_base_dir + '/' +  dir}.each {|path| child_dirs.push(Dir.glob(path + '/**/*/'))}
# child_dirs.flatten!
# child_dirs.reject! {|dir| dir.include? '@eaDir'} # trying to skip '@eaDir' in synology nas 
all_children = Dir.glob("#{items_base_dir}/**/*")
puts "[Hugo Contents Directories 2 MARKDOWN] There are total #{all_children.count} directories and files under '#{items_base_dir}'"
puts "[Hugo Contents Directories 2 MARKDOWN]"

default_index_front_matters = %w{title weight type lastmod}
index_front_matters = (default_index_front_matters + options["front_matters"]["index"]).uniq
# index_hash_template = Hash[index_front_matters.map {|x| [x, nil]}]
default_single_front_matters = []
single_front_matters = (default_single_front_matters + options["front_matters"]["single"]).uniq
# single_hash_template = Hash[single_front_matters.map {|x| [x, nil]}]

all_children.each_with_index do |path, i|
  puts "[Hugo Contents Directories 2 MARKDOWN] Examining #{path}"
  puts "[Hugo Contents Directories 2 MARKDOWN]"
  if File.directory?(path)
    puts "[Hugo Contents Directories 2 MARKDOWN] This is a directory. Proceeding accordingly..."
    puts "[Hugo Contents Directories 2 MARKDOWN]"
  
    # type = 'index'
    hash = Hash[index_front_matters.map {|x| [x, nil]}]

    directory_name = path.split('/').last
    hash["title"] = directory_name # if hash["title"]
    hash["type"] = 'page' # if hash["type"]
    # hash["weight"] = path.sub(items_base_dir, '').split('/').reject {|e| e.empty?}.count # if hash["weight"]
    hash["lastmod"] = File.mtime(path).strftime("%Y-%m-%d") # if hash["lastmod"]

    File.open(path + "/_index.md", "w") do |f|
      f.write(YAML.dump(JSON.parse(hash.to_json)))
      f << "---\n"
    end

    puts "[Hugo Contents Directories 2 MARKDOWN] Created \"#{path + '/_index.md'}\""
    puts "[Hugo Contents Directories 2 MARKDOWN]"

  elsif File.file?(path)
    puts "[Hugo Contents Directories 2 MARKDOWN] This is a file. Proceeding accordingly..."
    puts "[Hugo Contents Directories 2 MARKDOWN]"

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
      puts "[Hugo Contents Directories 2 MARKDOWN] initiating tag process..."
      puts "[Hugo Contents Directories 2 MARKDOWN] converting pdf to txt"
      `ruby ./pdf2txt.rb "#{path}"`
      puts "[Hugo Contents Directories 2 MARKDOWN] attempting to get natto"

      require 'natto'
      text = File.read(path + ".txt")
      nm = Natto::MeCab.new
      result = nm.enum_parse(text)
      # puts result
      tag_array = []
      result.each do |part|
        if ['NNG', 'NNP'].include?(part.feature.split(',').first) && part.surface.length > 1
          tag_array.push(part.surface)    
        end
      end
      # puts tag_array
      if tag_array.empty?
        hash["tags"] = [nil]
      else
        keyword_frequency_desc = tag_array.each_with_object(Hash.new(0)){ |m,h| h[m] += 1 }.sort_by{ |k,v| v }.reverse
        tags = []
        # puts keyword_frequency_desc.first(5).map{|w| w[0] }
        hash["tags"] = keyword_frequency_desc.first(5).map{|w| w[0] }
      end
      puts "[Hugo Contents Directories 2 MARKDOWN] natto done and cleaning up"
      File.delete(path + ".txt") if File.exists? (path + ".txt")
      puts "[Hugo Contents Directories 2 MARKDOWN] tag process done"
      puts "[Hugo Contents Directories 2 MARKDOWN]"
    else
      hash["tags"] = [nil]
    end
      
    extension = File.extname(path)
    md_file_path = path[0...-(extension.length)] + ".md"
    File.open(md_file_path, "w") do |f|
      f.write(YAML.dump(JSON.parse(hash.to_json)))
      f << "---\n"
    end
    puts "[Hugo Contents Directories 2 MARKDOWN] Created \"#{md_file_path}\""
    puts "[Hugo Contents Directories 2 MARKDOWN]"

  else
    puts "[Hugo Contents Directories 2 MARKDOWN] :::WARNING::: Check if #{path} is a valid path."
    next
  end
end
puts "[Hugo Contents Directories 2 MARKDOWN] Script End."

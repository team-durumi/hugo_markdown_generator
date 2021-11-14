#! /usr/bin/ruby
require 'yaml'
require 'json'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on("-b", "--base BASE_DIRECTORY") { |o| options[:base_directory] = o }
  opt.on("-r", "--host REMOTE_STORAGE_HOSTNAME") { |o| options[:remote_storage_hostname] = o }
  opt.on("-s", "--section ROOT_SECTION_TITLE (default: 'items')") { |o| options[:root_section_title] = o }
  opt.on("-w", "--which WHICH_FILENAME_FOR_FRONTMATTER ( 'self' / 'parent' )") { |o| options[:which_filename_for_frontmatter] = o }
end.parse!

puts "[Hugo Contents Directories 2 MARKDOWN]"
puts "[Hugo Contents Directories 2 MARKDOWN] Script ititiated."

unless File.exist?('front_matter_schema.yml')
  puts "[Hugo Contents Directories 2 MARKDOWN] front_matter_schema.yml does not exist. Script cannot proceed. Exiting the script."
  return false
end
front_matter_schema = YAML.load_file('front_matter_schema.yml')
index_front_matters = front_matter_schema["index"].select {|k, v| {k => v} unless v.nil? || v.compact.empty? }
single_front_matters = front_matter_schema["single"].select {|k, v| {k => v} unless v.nil? || v.compact.empty? }

unless !options.empty? && !options[:base_directory].nil?
  puts "[Hugo Contents Directories 2 MARKDOWN] Base directory specification required for the script to run. Re-run the script with '-h' for help."
  return false
end
unless File.directory?(options[:base_directory])
  puts "[Hugo Contents Directories 2 MARKDOWN] Invalid directory. Exiting the script."
  return false
end
base_directory = File.expand_path(options[:base_directory])

valid_option_for_which_filename_for_frontmatter = (%w{self parent}.include? options[:which_filename_for_frontmatter])
if !options.empty? && !options[:which_filename_for_frontmatter].nil? && !valid_option_for_which_filename_for_frontmatter
  puts "[Hugo Contents Directories 2 MARKDOWN] Invalid value for which_filename_for_frontmatter option. Exiting the script."
  return false
end

if options[:remote_storage_hostname].nil?
  if options[:root_section_title].nil?
    puts "[Hugo Contents Directories 2 MARKDOWN] You have not entered any root_section_title. Your file paths in markdown will have the default value of 'items'."
  else
    puts "[Hugo Contents Directories 2 MARKDOWN] You have entered \"#{options[:root_section_title]}\" as the hugo root section_title. This will be included in to your file paths."
  end
else
  puts "[Hugo Contents Directories 2 MARKDOWN] You have entered \"#{options[:remote_storage_hostname]}\" as the remote_storage_hostname for your content files. This will be prepended to your file paths."
end

puts
puts "Press 'Y' to continue the script or anything else to abort."
x = gets.chomp.upcase.strip
puts "You entered: #{x}"
unless x == 'Y'
  puts "[Ruby Markdown Generator 4 HUGO] Aborting the script as you wish."
  return false
end

puts "[Hugo Contents Directories 2 MARKDOWN] Proceeding with the script."
puts "[Hugo Contents Directories 2 MARKDOWN]"

puts "[Hugo Contents Directories 2 MARKDOWN] Inspecting directories under '#{base_directory}/'"
# valid_children = Dir.entries(base_directory).reject {|dir| %w{# .}.include? dir[0]} # trying to skip '#recycle' in synology nas 
# child_dirs = []
# valid_children.map {|dir| base_directory + '/' +  dir}.each {|path| child_dirs.push(Dir.glob(path + '/**/*/'))}
# child_dirs.flatten!
# child_dirs.reject! {|dir| dir.include? '@eaDir'} # trying to skip '@eaDir' in synology nas 
all_children = Dir.glob("#{base_directory}/**/*")
puts "[Hugo Contents Directories 2 MARKDOWN] There are total #{all_children.count} directories and files under '#{base_directory}'"
puts "[Hugo Contents Directories 2 MARKDOWN]"

all_children.each_with_index do |path, i|
  puts "[Hugo Contents Directories 2 MARKDOWN] Examining #{path}"
  puts "[Hugo Contents Directories 2 MARKDOWN]"
  if File.directory?(path)
    puts "[Hugo Contents Directories 2 MARKDOWN] This is a directory. Proceeding accordingly..."
    puts "[Hugo Contents Directories 2 MARKDOWN]"
  
    index_md_file_path = path + "/_index.md"
    if File.file?(index_md_file_path)
      puts "[Hugo Contents Directories 2 MARKDOWN] #{index_md_file_path} already exists. Skipping..."
      next 
    end
    
    hash = {}
    index_front_matters.map {|key, elements| key == 'array' ? elements.map {|e| hash[e] = [nil] } : elements.map {|e| hash[e] = nil } }

    if Dir.children(path).map {|e| path + '/' + e}.select {|a| File.directory?(a)}.empty? && valid_option_for_which_filename_for_frontmatter && options[:which_filename_for_frontmatter] == 'parent'
      hash["title"] = path.split('/').last.split('-')[1].split('_')[0] 
    else
      hash["title"] = path.split('/').last # directory_name
    end
    
    hash["type"] = 'page' 
    # hash["weight"] = path.sub(base_directory, '').split('/').reject {|e| e.empty?}.count
    hash["lastmod"] = File.mtime(path).strftime("%Y-%m-%d")

    File.open(index_md_file_path, "w") do |f|
      f.write(YAML.dump(JSON.parse(hash.to_json)))
      f << "---\n"
    end
    puts "[Hugo Contents Directories 2 MARKDOWN] Created \"#{path + '/_index.md'}\""
    puts "[Hugo Contents Directories 2 MARKDOWN]"
  elsif File.file?(path)
    puts "[Hugo Contents Directories 2 MARKDOWN] This is a file. Proceeding accordingly..."
    puts "[Hugo Contents Directories 2 MARKDOWN]"
    single_md_file_path = path[0...-(File.extname(path).length)] + ".md"
    if File.file?(single_md_file_path)
      puts "[Hugo Contents Directories 2 MARKDOWN] #{single_md_file_path} already exists. Skipping..."
      next
    end
    
    hash = {}
    single_front_matters.map {|key, elements| key == 'array' ? elements.map {|e| hash[e] = [nil] } : elements.map {|e| hash[e] = nil } }

    if valid_option_for_which_filename_for_frontmatter
      filename_index =  case options[:which_filename_for_frontmatter]
                        when 'parent'
                          -2
                        when 'self'
                          -1
                        end
      filename_for_data_use = path.split('/')[filename_index]
      delimiter = '-'
      hash["date"] = filename_for_data_use.split(delimiter)[0]
      hash["title"] = filename_for_data_use.split(delimiter)[1].split('_')[0] 
      hash["tags"] = filename_for_data_use.split(delimiter)[1].split('_').drop(1)
    else
      hash["title"] = File.basename(path).sub(File.extname(path), '')
    end

    root_section_title = options[:root_section_title].nil? ? 'items' : options[:root_section_title]
    component_path = path.sub(base_directory, root_section_title)
    remote_storage_hostname = options[:remote_storage_hostname].strip unless options[:remote_storage_hostname].nil?
    unless remote_storage_hostname.nil?
      component_path = component_path.sub(root_section_title + '/', remote_storage_hostname[-1] == '/' ? remote_storage_hostname : remote_storage_hostname + '/')
      component_path = component_path.gsub(' ', '+') if remote_storage_hostname.include?('amazonaws')
    end
    hash["components"] = [].push(component_path)

    # get tags from mecab
    if File.extname(path) == '.pdf'
      puts "[Hugo Contents Directories 2 MARKDOWN] initiating tag process..."
      puts "[Hugo Contents Directories 2 MARKDOWN] converting pdf to txt"
      `ruby ./pdf2txt.rb "#{path}"`
      puts "[Hugo Contents Directories 2 MARKDOWN] attempting to utilise mecab"

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
        puts "[Hugo Contents Directories 2 MARKDOWN] No valuable text for pdf file: #{path}"
      else 
        keyword_frequency_desc = tag_array.each_with_object(Hash.new(0)){ |m,h| h[m] += 1 }.sort_by{ |k,v| v }.reverse
        tags = []
        # puts keyword_frequency_desc.first(5).map{|w| w[0] }
        hash["tags"] = keyword_frequency_desc.first(5).map{|w| w[0] }
        puts "[Hugo Contents Directories 2 MARKDOWN] Tag applied."
      end
      puts "[Hugo Contents Directories 2 MARKDOWN] Cleaning up."
      # temporary_text_file_path = path + '.txt'
      # File.delete("#{temporary_text_file_path}") if File.exists? ("#{temporary_text_file_path}")
      File.delete(path + ".txt") if File.exists? (path + ".txt")
      puts "[Hugo Contents Directories 2 MARKDOWN] tag process done"
      puts "[Hugo Contents Directories 2 MARKDOWN]"
    end
    
    File.open(single_md_file_path, "w") do |f|
      f.write(YAML.dump(JSON.parse(hash.to_json)))
      f << "---\n"
    end
    puts "[Hugo Contents Directories 2 MARKDOWN] Created \"#{single_md_file_path}\""
    puts "[Hugo Contents Directories 2 MARKDOWN]"
  else
    puts "[Hugo Contents Directories 2 MARKDOWN] :::WARNING::: Check if #{path} is a valid path."
    next
  end
end
puts "[Hugo Contents Directories 2 MARKDOWN] Script End."

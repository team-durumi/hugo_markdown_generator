#! /usr/bin/ruby
require 'optparse'

puts "[Ruby Markdown Generator 4 HUGO]"
puts "[Ruby Markdown Generator 4 HUGO] Script ititiated."

options = {}
OptionParser.new do |opt|
  opt.on('-d', '--directory DIRECTORY') { |o| options[:directory] = o }
  opt.on('-r', '--remote_url REMOTE_URL') { |o| options[:remote_url] = o }
end.parse!

unless !options.empty? && !options[:directory].nil?
  puts "[Ruby Markdown Generator 4 HUGO] Root directory specification required for the script to run. Please re-run the script with '-h' for help."
  return false
end
hugo_items_dir = File.expand_path(options[:directory])
unless File.directory?(hugo_items_dir)
  puts "[Ruby Markdown Generator 4 HUGO] Invalid directory. Exiting the script."
  return false
end

if options[:remote_url].nil?
  puts "[Ruby Markdown Generator 4 HUGO] You have not entered any remote_url for your content files. This means that your markdown file will include local file paths."
else
  puts "[Ruby Markdown Generator 4 HUGO] You have entered \"#{options[:remote_url]}\" as the remote_url for your content files. This will be prepended to your file paths."
end
puts
puts "Press 'Y' to continue the script or anything else to abort."
x = gets.chomp.upcase.strip
puts "You entered: #{x}"
unless x == 'Y'
  puts "[Ruby Markdown Generator 4 HUGO] Aborting the script as you wish."
  return false
end
puts "[Ruby Markdown Generator 4 HUGO] Proceeding with the script."
puts "[Ruby Markdown Generator 4 HUGO]"

puts "[Ruby Markdown Generator 4 HUGO] Inspecting directories under '#{hugo_items_dir}/'"
child_dirs = Dir.glob(hugo_items_dir + '/**/*/')
puts "[Ruby Markdown Generator 4 HUGO] There are total #{child_dirs.count} directories under '#{hugo_items_dir}'"
puts "[Ruby Markdown Generator 4 HUGO]"
child_dirs.each_with_index do |dir_path, i|
  relative_directory = dir_path.sub(hugo_items_dir + '/', '')
  directory_name = dir_path.split('/').last
  puts "[Ruby Markdown Generator 4 HUGO]"
  puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | Inspecting directory: '#{relative_directory}'"
  if Dir.entries(dir_path).include?("_index.md")
    puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | '_index.md' already exists in '#{relative_directory}'"
  else
    puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | Creating '_index.md' file in '#{relative_directory}'"
    open(dir_path + '_index.md', 'w') { |f|
      f << "---\n"
      f << "lastmod: \n"
      f << "title: #{directory_name}\n"
      f << "weight: \n"
      f << "type: page\n"
      f << "---\n"
    }
    if File.exist?(dir_path + '_index.md')
      puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | '_index.md' created in '#{relative_directory}'"
    else
      puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | ERROR :::: '_index.md' failed to created in '#{relative_directory}' "
      return false
    end
  end
  puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | Checking if this directory has files contained."
  # valid_entries = Dir.glob("#{dir_path}*").reject{|var| File.extname(var) == '.md' } # this seems to include the folder itself.
  valid_entries = Dir.entries(dir_path).reject{|x| !File.file?(dir_path + x)  || x[0] == '.' || File.extname(x) == '.md'}
  if valid_entries.empty?
    puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | '#{relative_directory}' is not a directory that immediately contains files. Skipping..."
    puts "[Ruby Markdown Generator 4 HUGO]"
  else
    puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | '#{relative_directory}' has #{valid_entries.count} files contained."
    puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | "
    # file_paths = valid_entries
    file_paths = Dir.glob("#{dir_path}*").reject{|var| File.extname(var) == '.md' }
    file_paths.each_with_index do |file_path, j|
      relative_file_path = file_path.sub(hugo_items_dir+'/','')
      puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}-#{(j+1).to_s.rjust(4, "0")} | Inspecting '#{relative_file_path}'"
      remote_url = options[:remote_url].strip unless options[:remote_url].nil?
      filename = File.basename(file_path).sub(File.extname(file_path), '')
      extension = File.extname(file_path)
      md_file_path = file_path[0...-(extension.length)] + ".md"

      if File.exist?(md_file_path)
        puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}-#{(j+1).to_s.rjust(4, "0")} | Markdown file exists for '#{relative_file_path}'"
        puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | "
      else
        puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}-#{(j+1).to_s.rjust(4, "0")} | NO markdown file exists for '#{relative_file_path}'"
        puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}-#{(j+1).to_s.rjust(4, "0")} | Creating markdown file for '#{filename + extension}'"
        component_path = file_path.sub(hugo_items_dir, 'items')
        unless remote_url.nil?
          component_path = component_path.sub('items/', remote_url[-1] == '/' ? remote_url : remote_url + '/')
        end
        component_path = component_path.gsub(' ', '+') if remote_url.include?('amazonaws') 
        open(md_file_path, 'w') { |f|
          f << "---\n"
          f << "reference_code: \n"
          f << "date: \n"
          f << "draft: \n"
          f << "level_of_description: \n"
          f << "media_type: \n"
          f << "title: #{directory_name}-#{filename} \n"
          f << "description: \n"
          f << "weight: \n"
          f << "modified_at: \n"
          f << "created_at: \n"
          f << "link: \n"
          f << "components: \n"
          f << "  - \"#{component_path}\"\n"
          f << "tags: \n"
          f << "creators: \n"
          f << "subjects: \n"
          f << "sources: \n"
          f << "venues: \n"
          f << "public_access_status: \n"
          f << "copyright_status: \n"
          f << "---\n"
        }
        if File.exist?(md_file_path)
          puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}-#{(j+1).to_s.rjust(4, "0")} | '#{filename}.md' is successfully created."
          puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | "
        end
      end
    end
  end
end
puts "[Ruby Markdown Generator 4 HUGO]"
puts "[Ruby Markdown Generator 4 HUGO] Script END"

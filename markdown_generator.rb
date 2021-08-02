require 'optparse'

puts "[Ruby Markdown Generator 4 HUGO]"
puts "[Ruby Markdown Generator 4 HUGO] Script ititiated."
options = {}
OptionParser.new do |opt|
  opt.on('-d', '--directory DIRECTORY') { |o| options[:root] = o }
end.parse!
# puts options[:root].nil?
unless !options.empty? && !options[:root].nil?
  puts "[Ruby Markdown Generator 4 HUGO] Root directory specification required for the script to run. Please re-run the script with '-h' for help."
  return false
end
hugo_items_dir = File.expand_path(options[:root])
unless File.directory?(hugo_items_dir)
  puts "[Ruby Markdown Generator 4 HUGO] Invalid directory. Exiting the script."
  return false
end
  
puts "[Ruby Markdown Generator 4 HUGO] Inspecting directories under '#{hugo_items_dir}/'"
child_dirs = Dir.glob(hugo_items_dir + '/**/*/')
puts "[Ruby Markdown Generator 4 HUGO] There are total #{child_dirs.count} directories under '#{hugo_items_dir}'"
puts "[Ruby Markdown Generator 4 HUGO]"
child_dirs.each_with_index do |dir_path, i|
  relative_directory = dir_path.sub(hugo_items_dir + '/', '')
  directory_name = dir_path.split('/').last
  puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | Inspecting directory: '#{relative_directory}'"
  valid_entries = Dir.entries(dir_path).reject{|x| !File.file?(dir_path + x)  || x[0] == '.' || File.extname(x) == '.md'}
  # valid_entries = Dir.glob("#{dir_path}*").reject{|var| File.extname(var) == '.md' }
  if valid_entries.empty?
    puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | '#{relative_directory}' is not a directory that immediately contains files. Attempting to create '_index.md'..."
    if Dir.entries(dir_path).include?("_index.md")
      puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | '_index.md' already exists in '#{relative_directory}' Skipping..."
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
      puts "[Ruby Markdown Generator 4 HUGO] '_index.md' created in '#{relative_directory}'"
    end
    puts "[Ruby Markdown Generator 4 HUGO]"
  else
    puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}      | '#{relative_directory}' has #{valid_entries.count} files contained."
    puts "[Ruby Markdown Generator 4 HUGO]"
    # file_paths = valid_entries
    file_paths = Dir.glob("#{dir_path}*").reject{|var| File.extname(var) == '.md' }
    file_paths.each_with_index do |file_path, j|
      relative_file_path = file_path.sub(hugo_items_dir+'/','')
      puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}-#{(j+1).to_s.rjust(4, "0")} | Inspecting '#{relative_file_path}'"
      filename = File.basename(file_path).sub(File.extname(file_path), '')
      extension = File.extname(file_path)
      md_file_path = file_path[0...-(extension.length)] + ".md"
      if File.exist?(md_file_path)
        puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}-#{(j+1).to_s.rjust(4, "0")} | Markdown file exists for '#{relative_file_path}'"
      else
        puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}-#{(j+1).to_s.rjust(4, "0")} | NO markdown file exists for '#{relative_file_path}'"
        puts "[Ruby Markdown Generator 4 HUGO] ##{(i+1).to_s.rjust(3, "0")}-#{(j+1).to_s.rjust(4, "0")} | Creating markdown file for '#{filename + extension}'"
        open(md_file_path, 'w') { |f|
          f << "---\n"
          f << "reference_code: \n"
          f << "date: \n"
          f << "draft: \n"
          f << "level_of_description: \n"
          f << "media_type: \n"
          f << "title: #{filename} \n"
          f << "description: \n"
          f << "weight: \n"
          f << "modified_at: \n"
          f << "created_at: \n"
          f << "link: \n"
          f << "components: \n"
          f << "  - #{file_path.sub(hugo_items_dir, 'items')}\n"
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
        end
      end
      puts "[Ruby Markdown Generator 4 HUGO]"
    end
  end
end
puts "[Ruby Markdown Generator 4 HUGO] Script END"

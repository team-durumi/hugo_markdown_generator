#! /usr/bin/ruby
require 'csv'
require 'optparse'

options={}
OptionParser.new do |opt|
  opt.on('-f', '--file CSV_FILE_PATH') { |o| options[:file] = o }
  opt.on('-d', '--directory OUTPUT_DIRECTORY_PATH') { |o| options[:directory] = o }
end.parse!

unless !options.empty? && !options[:file].nil?
  puts "[Ruby Markdown Generator 4 HUGO] CSV_FILE option required for the script to run. Please re-run the script with '-h' for help."
  return false
end

unless !options.empty? && !options[:directory].nil?
  puts "[Ruby Markdown Generator 4 HUGO] OUTPUT_DIRECTORY_PATH option required for the script to run. Please re-run the script with '-h' for help."
  return false
end

csv_directory = options[:file]
unless File.exist?(csv_directory)
  puts "[Ruby Markdown Generator 4 HUGO] Invalid CSV file path. Exiting the script."
  return false
end

output_directory = File.expand_path(options[:directory])
unless File.directory?(output_directory)
  puts "[Ruby Markdown Generator 4 HUGO] Invalid output directory. Exiting the script."
  return false
end
# headers = CSV.read(csv_directory, headers: true).headers
data = CSV.read(csv_directory, headers: true)
data.each_with_index do |row , index|
  file_title = "#{row["reference_code"]}.md"
  open(output_directory + '/' + file_title, 'w') { |f|
    f << "---\n"
    # f << "#{} #{} \n"
    row.map do |k, v|
      f << "#{k}: #{v}\n"
    end
    f << "---\n"
  }
end

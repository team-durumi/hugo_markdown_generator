#! /usr/bin/ruby
require 'csv'
require 'optparse'

puts "[Ruby Markdown Generator 4 HUGO]"
puts "[Ruby Markdown Generator 4 HUGO] Script ititiated."

options={}
OptionParser.new do |opt|
  opt.on('-f', '--file CSV_FILE_PATH') { |o| options[:file] = o }
  opt.on('-d', '--directory OUTPUT_DIRECTORY_PATH') { |o| options[:directory] = o }
  opt.on('-t', '--taxonomy_terms TAXONOMY_TERMS( \' term term term \' )') { |o| options[:taxonomy_terms] = o }
  opt.on('-t' , '--taxonomy_terms TAXONOMY_TERMS( \'term term term\' )') { |o| options[:taxonomy_terms] = o }
  opt.on('-b' , '--boolean_field BOOLEAN_FIELD_TO_FILTER_TO_MARKDOWN') { |o| options[:boolean_field] = o }
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

if !options[:boolean_field].nil?
  puts "[Ruby Markdown Generator 4 HUGO] BOOLEAN_FIELD_TO_FILTER_TO_MARKDOWN = #{options[:boolean_field]}. This will only create markdown for the rows that have #{options[:boolean_field]} as TRUE."
else
  puts "[Ruby Markdown Generator 4 HUGO] You did not specify BOOLEAN_FIELD_TO_FILTER_TO_MARKDOWN option. This will create markdown for all the rows in CSV_FILE."
end

terms_array = []
if !options[:taxonomy_terms].nil?
  terms = options[:taxonomy_terms] + ' components'
else
  puts "[Ruby Markdown Generator 4 HUGO] You have not entered any taxonomy terms. Would you like to type them now?"
  puts
  puts "Press 'Y' to type in taxonomy terms or anything else to continue without it."
  x = gets.chomp.upcase.strip
  puts "You entered: #{x}"
  if x == 'Y'
    puts
    puts "Type terms to use as taxonomy terms. Please use space to write multiple terms."
    terms = gets.chomp.downcase.strip
    puts "You entered: #{terms}"
    terms = terms + ' components'
  else
    puts "[Ruby Markdown Generator 4 HUGO] Continuing without taxonomy terms."
    terms = 'components'
  end
end
terms.split(' ').each {|term| terms_array.push(term)}
terms_array = terms_array.uniq
puts "[Ruby Markdown Generator 4 HUGO] taxonomy_terms: #{terms_array}"
term_delimiter = "|"
puts "[Ruby Markdown Generator 4 HUGO] * taxonomy_term delimiter: \"#{term_delimiter}\" "
puts "[Ruby Markdown Generator 4 HUGO] "

puts "Press 'Y' to continue the script or anything else to abort."
x = gets.chomp.upcase.strip
unless x == 'Y'
  puts "[Ruby Markdown Generator 4 HUGO] Aborting the script as you wish."
  return false
end

puts "[Ruby Markdown Generator 4 HUGO] Proceeding with the script."
puts "[Ruby Markdown Generator 4 HUGO]"

# headers = CSV.read(csv_directory, headers: true).headers
data = CSV.read(csv_directory, headers: true)
data.each_with_index do |row , index|
  file_title = "#{row["reference_code"]}. #{row["title"]}.md"
  file_title = file_title.gsub('/', ',') if file_title.include?('/') # some titles seem to have '/'
  # puts file_title

  if !options[:boolean_field].nil? && row[options[:boolean_field]].strip.upcase != "TRUE"
    next
  end
  open(output_directory + '/' + file_title, 'w') { |f|
    f << "---\n"
    row.map do |k, v|
      if terms_array.include?(k)
        f << "#{k}: \n"
        v.split(term_delimiter).each do |vv|
          f << "  - \"#{vv.strip}\"\n"
        end
      else
        # f << "#{k}: #{v}\n"
        f << "#{k}: \"#{v}\"\n" # not sure if its better to wrap the content in quotation.
      end
    end
    f << "---\n"
  }
end
puts "[Ruby Markdown Generator 4 HUGO]"
puts "[Ruby Markdown Generator 4 HUGO] Script END"

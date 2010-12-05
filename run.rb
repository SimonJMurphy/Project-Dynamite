#!/usr/bin/env ruby
require 'optparse'
require_relative 'kepler_processor.rb'

options = { :command => KeplerProcessor::Convertor, :input_path => [], :output_path => "data/output" }

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby run.rb -c command -i path_to_input_file [-o output_directory]"
  opts.on("-c", "--command COMMAND", String, "Specify the command to run [convert/transform]") do |c|
    options[:command] = { "convert" => KeplerProcessor::Convertor, "transform" => KeplerProcessor::Transformer }[c]
    if options[:command].nil?
      puts "Invalid command. Options are [convert/transform`]"
      puts opts
      exit
    end
  end
  opts.on("-f", "--[no-]force_overwrite", "Force overwrite existing output files") do |f|
    options[:force_overwrite] = f
  end
  opts.on("-i", "--input PATH", Array, "Specify the path to the input file") do |p|
    options[:input_path] = p
  end
  opts.on("-o", "--output PATH", String, "Specify the path to the output directory. Defaults to data/output") do |p|
    options[:output_path] = p
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

begin
  option_parser.parse!
rescue
  puts $! # print out error
  option_parser.parse('--help') # print out command glossary
end

options[:input_path].each do |filename|
  begin
    c = options[:command].new(filename, options[:output_path], options[:force_overwrite])
    c.run
  rescue KeplerProcessor::FileExistsError
    puts "Your output file (#{c.full_output_filename}) already exists, please remove it first (or something)."
  end
end

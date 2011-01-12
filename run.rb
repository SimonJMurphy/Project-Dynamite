#!/usr/bin/env ruby
require 'optparse'
require_relative 'kepler_processor.rb'

options = { :command => KeplerProcessor::Convertor, :input_path => [], :output_path => "data/output", :transform => :dft, :samplerate =>  450.0 }

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby run.rb -c command -i path_to_input_file [-o output_directory]"
  opts.on("-c", "--command COMMAND", String, "Specify the command to run [convert/transform/merge]") do |c|
    options[:command] = { "convert" => KeplerProcessor::Convertor, "transform" => KeplerProcessor::Transformer, "merge" => KeplerProcessor::Merger }[c]
    if options[:command].nil?
      puts "Invalid command. Options are [convert/transform/merge/]"
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
  opts.on("-m", "--merge-ratio RATIO", Integer, "Specify a merge ratio to use.") do |p|
    options[:merge_ratio] = p
  end
  opts.on("--fft", "Perform a Fast Fourier Transform (quicker)") do
    options[:transform] = :fft
  end
  opts.on("-r", "--samplerate SAMPLERATE", Float, "Specify the sample rate of the generated signal") do |r|
    options[:samplerate] = r
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

if options[:command] == KeplerProcessor::Merger && !options.has_key?(:merge_ratio)
  puts "You must provide an integer merge ratio"
  option_parser.parse('--help')
  exit
end

options[:input_path].each do |filename|
  begin
    c = options[:command].new(filename, options)
    c.run
  rescue KeplerProcessor::FileExistsError
    puts "Your output file (#{c.full_output_filename}) already exists, please remove it first (or something)."
  end
end

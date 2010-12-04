#!/usr/bin/env ruby
require_relative 'kepler_processor.rb'

# abort the execution if no filename is provided as an argument with the program call
Kernel.abort "Please pass the input filename as an argument! Use -f to force overwrite." if ARGV.size < 1
possible_methods = { "convert" => KeplerProcessor::Convertor, "transform" => KeplerProcessor::Transformer }
method = ARGV.delete_at 0

force_overwrite = false
if ARGV.first == "-f" # the zeroth element of ARGV, equivalent of ARGV[0]
  force_overwrite = true
  ARGV.delete_at 0 # need to remove the -f because it's not a filename we want to convert.
end

ARGV.each do |filename|
  begin
    possible_methods[method].new(filename, force_overwrite).run
  rescue KeplerProcessor::FileExistsError
    puts "Your output file (#{filename}) already exists, please remove it first (or something)."
  end
end

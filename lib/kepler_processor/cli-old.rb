require 'rubygems'
require 'optparse'
require 'logger'
require 'kepler_processor'

LOGGER = Logger.new STDOUT
LOGGER.level = Logger::INFO

module KeplerProcessor
  class CLI
    def self.start
      options = { :command => KeplerProcessor::Convertor, :input_paths => [], :output_path => "data/output", :file_columns => [0,1], :column_delimiter => " ", :column_converters => :float }

      option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: kepler -c command [-o output_directory] [--columns 0,1] [-d ,] path_to_input_file(s)"

        opts.on("-c", "--command COMMAND", String, "Specify the command to execute [convert/transform/merge/append/plot_lc/uniquify/catalogue/slice]") do |c|
          options[:command] = { "convert" => KeplerProcessor::Convertor, "transform" => KeplerProcessor::Transformer, "merge" => KeplerProcessor::Merger, "plot_lc" => KeplerProcessor::LightCurvePlotter, "uniquify" => KeplerProcessor::IndexDupRemover, "catalogue" => KeplerProcessor::CatalogueMaker, "append" => KeplerProcessor::Appender, "slice" => KeplerProcessor::Slicer, "detrend" => KeplerProcessor::Detrender }[c]
          if options[:command].nil?
            LOGGER.error "Invalid command. Options are [convert/transform/merge/append/plot_lc/uniquify/catalogue/slice]"
            puts opts
            exit
          end
        end
        opts.on("-f", "--[no-]force_overwrite", "Force overwrite existing output files") do |f|
          options[:force_overwrite] = f
        end
        opts.on("-C", "--columns 0,1", Array, "Choose input file columns to be read. Defaults to 0,1") do |f|
          options[:file_columns] = f.map(&:to_i)
        end
        opts.on("-d", "--delimiter DELIMITER", String, "Specify delimiting character. Defaults to a single space") do |f|
          options[:column_delimiter] = f
        end
        opts.on("-o", "--output PATH", String, "Specify the path to the output directory. Defaults to data/output") do |p|
          options[:output_path] = p
        end
        opts.on("-m", "--merge-ratio RATIO", Integer, "Specify a merge ratio to use.") do |p|
          options[:merge_ratio] = p
        end
        opts.on("-s", "--slice-size SIZE", Integer, "Specify a slice size to use.") do |p|
          options[:slice_size] = p
        end
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
        opts.on_tail("-v", "--version", "Show version") do
          puts KeplerProcessor::VERSION
          exit
        end
      end

      if ARGV.size.zero?
        option_parser.parse '--help'
      else
        begin
          options[:input_paths] = option_parser.parse! # returns anything not handled by the options above - the input filenames.
        rescue
          LOGGER.error $! # print out error
          option_parser.parse '--help' # print out command glossary
        end
      end

      if options[:command] == KeplerProcessor::Merger && !options.has_key?(:merge_ratio)
        LOGGER.error "You must provide an integer merge ratio"
        option_parser.parse '--help'
        exit
      end

      if options[:command] == KeplerProcessor::Slicer && !options.has_key?(:slice_size)
        LOGGER.error "You must provide an slice size (in days)"
        option_parser.parse '--help'
        exit
      end

      options[:command].new(options).execute!

      LOGGER.close
    end
  end
end
require 'thor'

module KeplerProcessor
  class CLI < Thor

    no_tasks do
      def self.common_method_options
        method_option :input_paths, :type => :array, :required => true, :banner => 'input_file_1.txt input_file_2.txt', :desc => 'Specify the input files to be processed'
        method_option :output_path, :aliases => '-o', :desc => 'Specify the path to the output directory', :default => 'data/output'
        method_option :force_overwrite, :aliases => '-f', :type => :boolean, :desc => 'Force overwrite existing output files'
        method_option :file_columns, :aliases => '-c', :type => :array, :desc => 'Choose input file columns to be read', :default => [0,1]
        method_option :delimiter, :aliases => '-d', :type => :string, :desc => 'Specify delimiting character', :default => ' '
      end

      def clean_options
        options[:file_columns].map! &:to_i
      end
    end

    desc 'version', 'Print version info for Kepler Processor'
    map %w(-v --version) => :version
    def version
      puts "Kepler Processor v#{KeplerProcessor::VERSION}"
    end

  end
end
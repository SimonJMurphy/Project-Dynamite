require 'thor'

module KeplerProcessor
  class CLI < Thor

    desc 'version', "Print version info for Kepler Processor"
    map %w(-v --version) => :version
    def version
      puts KeplerProcessor::VERSION
    end

  end
end
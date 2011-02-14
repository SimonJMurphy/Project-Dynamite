module KeplerProcessor
  class Base
    def initialize(options)
      @options = options
    end

    def run(runner)
      @options[:input_paths].each do |filename|
        begin
          c = runner.new filename, @options
          c.run
        rescue KeplerProcessor::FileExistsError
          LOGGER.info "Your output file (#{c.full_output_filename}) already exists, please remove it first (or something)."
        rescue => e
          LOGGER.error e.exception
        ensure
          c = nil
        end
      end
    end
  end
end

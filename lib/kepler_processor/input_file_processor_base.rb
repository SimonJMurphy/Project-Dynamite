require 'fileutils'
require 'csv'

module KeplerProcessor
  class InputFileProcessorBase

    attr_accessor :input_filename, :input_filename_without_path, :input_filename_without_extension, :input_data, :output_data, :options, :attributes, :comments

    def initialize(input_filename, options = {})
      @input_filename                   = input_filename
      input_filename_without_path       = @input_filename.split("/").last.split(".")
      @input_filename_without_path      = input_filename_without_path.join '.'
      input_filename_without_path.delete_at(-1)
      @input_filename_without_extension = input_filename_without_path.join '.'
      @options                          = options
      @input_data                       = []
      @txt_save                         = true
    end

    def execute!
      LOGGER.info "Processing file #{@input_filename}"
      read_in_data
      split_comments!
      parse_header_attributes
      select_appropriate_columns
      yield if block_given?
      save! if @txt_save
      LOGGER.info "Finished processing file #{@input_filename}"
    end

    def read_in_data
      @input_data = CSV.read @input_filename, :col_sep => @options[:column_delimiter], :converters => @options[:column_converters]
      raise NoDataError if @input_data.empty?
    end

    private

      def split_comments!
        # matches (=~) regular expression (/../) hash at start of line (^), preceeded by any number of spaces (\s*)
        @comments, @input_data = @input_data.partition { |line| line[0] =~ /^#/ }
      end

      def parse_header_attributes
        # select lines from comments containing a colon, map them into an array, remove the '#' and split
        # about that colon. Create a hash out of the result.
        @attributes = @comments.select { |line| line.any? { |x| x.is_a?(String) ? x.include?(":") : false } }.map do |line|
          line.map! { |x| x.is_a?(String) ? x.split(" ") : x }.flatten!
          line.delete_at 0
          value = line.delete_at(-1).to_s
          [line.join(" ").split(":").first, value]
        end.to_hash
        @attributes[:kic_number] = @attributes[:kic_number].to_i if @attributes[:kic_number]
        @attributes[:kic_number] ||= @input_filename_without_path.split("_").first
        @attributes[:season] ||= @input_filename_without_path.split("_")[2]
        @attributes[:cadence] ||= @input_filename_without_path.split("_")[3]
      end

      def select_appropriate_columns
        # convert @input_data to a two dimensional float array: time, flux
        @input_data.map! do |line|
          @options[:file_columns].map { |x| line[x] }
        end
      end

      include Saveable

  end
end

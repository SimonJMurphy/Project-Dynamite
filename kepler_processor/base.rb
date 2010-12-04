module KeplerProcessor
  class Base
    def initialize(input_filename, force_overwrite)
      @input_filename = input_filename
      @force_overwrite = force_overwrite
      @input_data = []
    end

    def run
      puts "Processing file #{@input_filename}"
      read_in_data
      split_comments!
      parse_header_attributes
      convert_from_string!
      yield
      save!
      puts "Finished processing file #{@input_filename}"
    end

    private

      def read_in_data
        File.new(@input_filename, "r").each { |line| @input_data << line }
        # file closes automatically because it's opened in this method
        raise NoDataError if @input_data.empty?
      end

      def split_comments!
        @comments, @input_data = @input_data.partition { |line| line =~ /^#/ } # matches (=~) regular expression (//) hash at start of line (^)
      end

      def parse_header_attributes
        # selects lines from comments containing a colon, maps them into an array, removing the '#' and splitting about that colon. Creates a hash out of the result.
        @attributes = @comments.select { |line| line.include? ":" }.map { |line| line.gsub("# ", "").split ":" }.to_hash
      end

      def convert_from_string!
        # @input_data is being converted to a two dimensional float array: time, flux
        @input_data.map! { |line| line.split(" ").map(&:to_f)[0..1] }
      end

      def output_filename
        nil # defaults to nil, child class must override output_filename in order to save.
      end

      def save!
        if output_filename
          @output_data ||= @input_data
          raise FileExistsError if File.exist?(output_filename) && !@force_overwrite
          output_file = File.new output_filename, "a+" # 'a' for all - read, write... everything
          output_file.truncate(0) if @force_overwrite # essentially confines the size of the file to zero if forcibly overwritten, thereby emptying the file.
          @output_data.each { |record| output_file << "#{record.join("\t")}\n" } # outputs the array, joining each row element separated by tab, and each line by newline.
        end
      end
  end
end

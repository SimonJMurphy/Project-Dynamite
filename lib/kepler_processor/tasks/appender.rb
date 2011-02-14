module KeplerProcessor
  class Appender < TaskRunBase

    def run
      super do
        append!
      end
    end

    private

     def append!
       # comments are already partitioned off in base
       # directly after last datapoint of first file, first datapoint of next file should be added to @input_data
       # continue for all files given
       # reinsert the partitioned comments, but change the 'season' parameter's value to read 'multiple' or something more specific if possible
       # require condition that there are at least two files.
       # all files must have the same kic number
     end

  end
end

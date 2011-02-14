require 'gnuplot'
require 'kepler_dft'

require_relative 'kepler_processor/monkey_patches.rb'

module KeplerProcessor
  class FileExistsError < StandardError; end
  class NoDataError < StandardError; end
end

require_relative 'kepler_processor/base.rb'
require_relative 'kepler_processor/task_run_base.rb'
require_relative 'kepler_processor/tasks.rb'
require_relative 'kepler_processor/version.rb'

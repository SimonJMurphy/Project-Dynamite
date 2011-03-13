(%w{logger
  gnuplot
  gsl
  kepler_dft
  kepler_processor/cli
  kepler_processor/monkey_patches
  kepler_processor/fourier_transformable
  kepler_processor/saveable
  kepler_processor/input_file_processor_base
  kepler_processor/task_base
  kepler_processor/multifile_task_base
  kepler_processor/version} + Dir[File.dirname(__FILE__) + '/kepler_processor/tasks/*.rb']).each { |file| require file }

module KeplerProcessor
  class FileExistsError < StandardError; end
  class NoDataError < StandardError; end
end

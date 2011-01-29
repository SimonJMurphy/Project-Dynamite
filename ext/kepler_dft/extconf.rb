# Loads mkmf which is used to make makefiles for Ruby extensions
require 'mkmf'

extension_name = 'kepler_dft'
dir_config extension_name
create_makefile extension_name
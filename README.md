Kepler Processor
================

Installation
------------
Make sure you have GNUPlot installed with support for output to png.

Then:

    gem install kepler-processor

Usage
-----
    kepler -C command filename(s)

See kepler --help for details

Tasks
-----

### Convertor

Convertor is designed to take the raw kepler data, as downloaded from kasoc, and to convert it into something more usable. As it comes, the data contains multiple columns including: time, raw flux, raw flux error, corrected flux, and corrected flux error. Normally the user will select two columns to convert, and the output file will then contain just two columns, typically time and flux or corrected flux.

Typical usage:

    kepler -c convert -C 0,3 -f data/input/filename.txt

This executes the convert command on columns 0 and 3 (time and corrected flux) of the file 'filename.txt' with relative path data/input/. Mutliple files can be converted simultaneously with, for example, data/input/*.txt as the input filename argument. As with all tasks, the input filename(s) must always be the final argument.

Other useful options on convertor are '-f' (force overwrite) which automatically overwrites existing files with the same output filename in the output directory. The standard output directory is data/output, and convertor has the default filename format kic#\_CFlux\_{quarter}\_{short/long cadence}.txt, e.g "kic1234567\_CFlux\_Q6.1_slc.txt".

Convertor will delete any lines containing "-Inf", or containing imaginary numbers (containing 'i'). Any headers in the file are taken out if they start with the # character. All fluxes are converted to magnitudes, and are centered about zero.

### Merger

Merger is designed for use on excessively large files. It is preferable to have longer datasets for increased resolution, but having more data points massively increases computation time for fourier transforms and other tasks. With Merger you can take a user-specified number of points, given as the merge-ratio, and merge those points into a single point, whose time and flux values are the average of those points. Merger does not merge points if a gap in the data exists between them. So if points are separated in time by more than the normal separation in time of points with that particular cadence, then that set of points are not merged. The next set of points, if free of time gaps, will merge normally. Points at the end of the file that are insufficient in number for form a whole set to be merged are also not merged.

Typical usage:

    kepler -c merge -m 10 data/output/filename.txt

Note that Merger is designed to run on files that are already converted, and the input file will likely reside in the directory data/output/. Merger requires a merge-ratio. This is given with "-m" and then the merge-ratio, separated either side by a space. Users may also find the force overwrite option useful. The filename provided by merger is the same as that of convertor, but with "\_{merge_ratio}to1" inserted before the cadence.

### Transformer

Transformer is designed to work on converted files. A fourier transform of the converted data is calculated and plotted. If the data are short cadence, the transform is calculated from 0 to 100 c/d, whereas long cadence data is only calculated to 24 cycles per day. Therefore plots of 0-24 c/d are plotted irrespective of cadence, and an extra plot of 0-100 c/d is plotted for short cadence data. The time span of the plot is reflected in the filename of the plot.

Typical usage:

    kepler -c transform data/output/filename.txt

Transformer is a ruby program that passes arguments to a program written in c to perform its calculations, because c was found to be much quicker than ruby at this task. The transform calculation code has the inner and outer for loops switched compared to those of Deeming, 1975, and trigonometric identities are used to further reduce the number of computationally expensive sine and cosine calculations.

### Light Curve Plotter

Light Curve Plotter plots a light curve of the input data. The output filename of the plot is the same as that of the input filename, with _plot.png instead of .txt, and is produced in /data/output by default.

Typical usage:

    kepler -c plot_lc data/output/filename.txt

### Catalogue Maker

Catalogue Maker requires more scaffolding than other tasks. Firstly, there must be an observation index with a list of stars for which the catalogue is to be made, along with their key parameters. This is passed to Catalogue Maker as the input filename argument at the command line.

Typical usage:

    kepler -c catalogue data/input/observation_index.txt

By default, Catalogue Maker reads the input file as a list of comma separated values, rather than values separated by spaces, because this is the typical format of observation indexes when downloaded through kasoc. It is assumed that the table has nine columns, containing: (left to right) kic\_number, cadence, season, magnitude, Teff, radius, log g, metallicity and contamination. If this is not the case, line 28 of catalogue_maker.rb will need to be changed according to the contents of the index.

For each observation cycle listed in the observation index, there must be a light curve and the correct number of fourier plots (one for long cadence, two for short) in the folder CATALOGUE\_IMAGES_PATH (line 14).

The catalogue created is in pdf format, with one observation cycle per page. Catalogue Maker sorts the observation index by kic number and then by season so that the pages are in a sensible order.

### Appender

Appender is designed to combine consecutive raw data files into a single data file, before conversion. This removes some systematic errors from converting the files first, and appending them afterwards.

Development
-----------

* Do `bundle install` to get all of the development dependencies.
* Do `rake features` to run the acceptance tests
* Do `rake spec` to run the RSpec examples
* Do `bundle exec kepler` to manually run the app for testing

Note on Patches/Pull Requests
-----------------------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself so I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2011 Simon Murphy, Ben Langfeld. MIT licence (see LICENSE for details).

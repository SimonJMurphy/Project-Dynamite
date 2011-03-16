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

Transformer is a ruby program that passes arguments to a program written in c to perform its calculations, because c was found to be much quicker than ruby at this task. The transform calculation code has the inner and outer for loops switched compared to those of Deeming (1975), and trigonometric identities are used to further reduce the number of computationally expensive sine and cosine calculations.

### Light Curve Plotter

Light Curve Plotter plots a light curve of the input data. The output filename of the plot is the same as that of the input filename, with _plot.png instead of .txt, and is produced in /data/output by default.

Typical usage:

    kepler -c plot_lc data/output/filename.txt

### Catalogue Maker

Catalogue Maker requires more scaffolding than other tasks. Firstly, there must be an observation index with a list of stars for which the catalogue is to be made, along with their key parameters. This is passed to Catalogue Maker as the input filename argument at the command line.

Typical usage:

    kepler -c catalogue data/input/observation_index.txt

By default, Catalogue Maker reads the input file as a list of comma separated values, rather than values separated by spaces, because this is the typical format of observation indexes when downloaded through kasoc. It is assumed that the table has nine columns, containing: (left to right) kic\_number, cadence, season, magnitude, Teff, radius, log g, metallicity and contamination. If this is not the case, line 28 of catalogue_maker.rb will need to be changed according to the contents of the index.

For each observation cycle listed in the observation index, there must be a light curve and the correct number of fourier plots (one for long cadence, two for short) in the folder CATALOGUE\_IMAGES\_PATH (line 14).

The catalogue created is in pdf format, with one observation cycle per page. Catalogue Maker sorts the observation index by kic number and then by season so that the pages are in a sensible order.

### Appender

Appender is designed to combine consecutive raw data files into a single data file, before conversion. This removes some systematic errors from converting the files first, and appending them afterwards. The files to be appended must have the same kic\_number, and are assumed to be adjacent in time. They are sorted by season before appending.

Since the comments of unconverted files contain information about the kic\_number and the season, appender reinserts these into the first two lines of the appended data. These are written in as comments (lines start with '#'), looking like they would in files that have not been appended. Therefore, convertor will work as it does on non-appended files. The season will be written as a range, in the form {first season}-{final season}, and this is reflected in the output filename.

Typical usage:

    kepler -c append data/input/kplr001234567*.txt

where kplr001234567 is a unique object with only adjacent quarters.

### Slicer

Slicer is designed to take a converted dataset and cut it up into user-specified pieces. The length of these pieces are specified (in days) as the slice-ratio (-s). Slicer counts these days in terms of one day's worth of points, rather than one day in time. Therefore, if there is a gap in the middle of a slice, the time between the final and initial points in the slice will be more than one day. As the time gap between each point of long cadence data is roughly 0.02, there will be 50 points in one day's worth of LC data. if a half-day time gap were to lay in the middle of this slice, the total length of the slice would therefore be 1.5 days.

Slicer determines whether the data is long or short cadence by the filename, and bases the number of points in a slice from that. Users should note that the final slice will almost always be incomplete, and should account for this in their analyses.

The output filename indicates the length of the slices and the part\_number of that slice - a 90 day dataset split into 2 day slices will have 45 slices in parts from 0 to 44. Since it is often appended data that is sliced, such an example is presented below.

Typical usage:

    kepler -c slice -s 2 data/output/kic01234567-appended_Q2.1-Q2.3_slc.


### Modulation Finder

Modulation finder seeks to identify variations in the frequency and amplitude of the maximum peak in a dataset's transform over time. The function of the program is to make a fourier transform of slices of data, find the highest peak in each one, and write the frequency and amplitude of that peak into an array. This array of peaks is built up for every slice, and then the frequencies and amplitudes are handled separately: each are plotted as a function of time (time is the mid-point of each slice), and a fourier transform of that is run for each to determine if there is a pattern in the variation of either frequency or amplitude with time.

Modulation finder automatically transforms the data within the Nyquist limit, by calculating the time-span of the slices and using half of that time as the upper frequency limit in the transform. The user must therefore be clever in selecting the correct slice size to unravel the secrets of the data - too short and the frequency of variation will be above the Nyquist; too long and there are too few points for a meaningful transform.

The mid-point of each data slice is found automatically, and the sliced dataset is automatically sorted into part-order before other processes are implemented.

Typical usage:

    kepler -c find_mod data/output/01234567_slices/kic01234567_CFlux_Q2.1-2.3_1d-slices-part*.txt

where the slices have been kept in a separate directory within the output directory.

The mean and standard deviation of both the frequencies and the amplitudes are written to the terminal.

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

Kepler Processor
================

Installation
------------
Make sure you have GNUPlot installed with support for output to png -- this is normally via libgd and dependencies.

Then:

    gem install kepler-processor

Usage
-----
    kepler -C command -o output-path filename(s)

See kepler --help for details
In the examples below, the -o has been omitted for brevity.

Tasks
-----

### Convertor

Convertor is designed to take the raw Kepler data, as downloaded from kasoc, and to convert it into something more usable. As it comes, the data contains multiple columns including: time, raw flux, raw flux error, corrected flux, and corrected flux error. Normally the user will select two columns to convert, and the output file will then contain just two columns, typically time and SAP flux or PDC flux.

Typical usage:

    kepler -c convert -t 'msMAP' -C 0,1 -f -o ~/data/output ~/data/input/filename.txt

This executes the convert command on columns 0 and 1 (time and raw flux) of the file 'filename.txt' with relative path ~/data/input/. The default setting for the columns to convert is 0,3 (time and PDC flux). Multiple files can be converted simultaneously with, for example, ~/data/input/*.txt as the input filename argument. As with all tasks, the input filename(s) must always be the final argument.

Other useful options on convertor are '-f' (force overwrite), which automatically overwrites existing files with the same output filename in the output directory, and '-b' (batch), which uses a different output filename that is more useful for converting large batches of data, typically one working group at a time. The batch output filename uses the working group number from the input folder e.g. ~/data/input/wg4 => ~/data/output/converted\_wg4. Remember to specify the output directory. Convertor has the default filename format kic#\_{flux\_type}\_{quarter}\_{short/long cadence}.txt, e.g. "kic1234567\_msMAP\_Q6.1\_slc.txt". If this file-naming convention is undesirable because of a non-standard input filename, the option '-k' will keep the input filename and just insert '\_converted' before the file extension '.txt'.

Convertor will delete any lines containing "-Inf", or containing imaginary numbers (containing 'i'). Any headers in the file are taken out if they start with the # character. All fluxes are converted to magnitudes, and are centred about zero. Convertor requires the user to specify which type of flux the data are using "-t". The convention commonly used is 'LS' for PDC-LS, 'msMAP' for PDC-multiscale-MAP and "SAP" for the Simple Aperture Photometry.

An option exists (-m) for switching from the time notation of MAST data files, where time is relative to 1st Jan 2009, to the kasoc format of truncated Barycentric Julian date. In addition, if data from MAST containing a SAP\_Quality column (third column) are used, then specifying "-g" will use only the points with 'good' SAP\_Quality (==0).

Running convertor takes around one second per long-cadence light-curve, and five seconds per short-cadence light-curve.

### Merger

Merger is designed for use on excessively large files. It is preferable to have longer datasets for increased frequency resolution, but having more data points massively increases computation time for fourier transforms and other tasks. With Merger you can take a user-specified number of points, given as the merge-ratio, and merge those points into a single point, whose time and flux values are the average of those points. Merger does not merge points if a gap in the data exists between them. So if points are separated in time by more than the normal separation in time of points with that particular cadence, then that set of points are not merged. The next set of points, if free of time gaps, will merge normally. Points at the end of the file that are insufficient in number to form a whole set to be merged are also not merged. The algorithms will merge short-cadence (SC) data into long-cadence (LC) data and produce concurrent data points (with those expected in the LC light curve), but the SC light curve needs engineering such that there are exactly 15 points in the SC data set before the first point in the LC dataset.

Typical usage:

    kepler -c merge -r 10  -o ~/data/output ~/data/output/filename.txt

Note that Merger is designed to run on files that are already converted. Hence there is normally no need to specify which columns to use because the file will only have times and fluxes. Merger requires a merge-ratio. This is given with "-r" and then the merge-ratio, separated either side by a space. Users may also find the force overwrite option useful. The filename provided by merger is the same as that of convertor, but with "\_{merge_ratio}to1" inserted before the cadence.

### Transformer

Transformer is designed to work on converted files. A fourier transform of the converted data is calculated and plotted. If the data are short cadence, the transform is calculated from 0 to 100 c/d, whereas long cadence data is only calculated to 24 cycles per day. Therefore plots of 0-24 c/d are plotted irrespective of cadence, and an extra plot of 0-100 c/d is plotted for short cadence data. The time span of the plot is reflected in the filename of the plot.

Typical usage:

    kepler -c transform [-f -e -i 5,24 -w 4] -o ~/data/output/example_catalogue_images ~/data/output/filename.txt

Using "-i" allows the user to specify the frequencies inbetween which the Fourier transform will be calculated. The option "-e" will export the fourier information to a text file called "fourier_information" in the output directory. It contains the kic number, season, peak amplitude (mmag), the frequency of that peak (c/d) and the grass level (mmag). The grass-level calculation takes ~1-c/d slices (4-c/d in SC) and calculates the 95th percentile of peak amplitudes in each slice. The median of that 95th percentile as measured over all slices is then assumed to be representative of the grass level. The force-overwrite "-f" command is required to append to this file when processing multiple time-series. To save computation time, the "-w" option can be used. This determines the step rate of the Fourier transform, as 1/(w*T) where T is the data set length and w is the float supplied with the -w option. Note that the FT is data-point limited. Exceptionally long data sets, large frequency ranges and/or high step rates will cause a segmentation fault.

Transformer is a ruby program that passes arguments to a program written in c to perform its calculations, because c was found to be much quicker than ruby at this task. The transform calculation code has the inner and outer for loops switched compared to those of Deeming (1975), and trigonometric identities are used to further reduce the number of computationally expensive sine and cosine calculations.

### Light Curve Plotter

Light Curve Plotter plots a light curve of the input data. The output filename of the plot is the same as that of the input filename, with _plot.png instead of .txt, and is produced in /data/output by default.

Typical usage:

    kepler -c plot_lc -o ~/data/output/example_catalogue_images ~/data/output/filename.txt

Plotting light curves takes around half a second per long-cadence light-curve, and around five seconds per short-cadence light-curve.

### Catalogue Maker

Catalogue Maker requires more scaffolding than other tasks. Firstly, there must be an observation index with a list of stars for which the catalogue is to be made, along with their key parameters. This is passed to Catalogue Maker as the input filename argument at the command line.

Typical usage:

    kepler -c catalogue [-i 5,24] -o ~/data/output ~/data/input/example_observation_index.txt

where the -i option allows the user to specify the 'fourier range' of the Fourier transforms that will be used for the catalogue, so that the correct filenames of those Fourier transforms are identified.

By default, Catalogue Maker reads the input file as a list of comma separated values, rather than values separated by spaces, because this is the typical format of observation indexes when downloaded through kasoc. It is assumed that the table has nine columns, containing: (left to right) kic\_number, cadence, season, magnitude, Teff, radius, log g, metallicity and contamination. If this is not the case, line 28 of catalogue_maker.rb will need to be changed according to the contents of the index.

For each observation cycle listed in the observation index, there must be a light curve and the correct number of fourier plots (one for long cadence, two for short) in the folder CATALOGUE\_IMAGES\_PATH (line 14), e.g. ~/data/output/example\_catalogue\_images. There is a hard-coded expectation that the flux type of the Fourier transforms and light curve plots is 'msMAP'. The flux type is also added to the catalogue.

The catalogue created is in pdf format, with one observation cycle per page. Catalogue Maker sorts the observation index by kic\_number and then by season so that the pages are in a sensible order. The path and filename of the catalogue produced is ~/data/output/example_catalogue.pdf.

Making the catalogue, once the catalogue\_images directory is fully populated, takes about 6 seconds per 200 pages.

### Appender

Appender is designed to combine consecutive raw data files into a single data file, before conversion. This removes some systematic errors from converting the files first, then appending them afterwards. The files to be appended must have the same kic\_number, and are assumed to be adjacent in time. They are sorted by season before appending. Note that converted files are easily appended using the concatenating command in terminal: cat FileA FileB

Since the comments of unconverted files contain information about the kic\_number and the season, appender reinserts these into the first two lines of the appended data. These are written in as comments (lines start with '#'), looking like they would in files that have not been appended. Therefore, convertor will work as it does on non-appended files. The season will be written as a range, in the form {first season}-{final season}, and this is reflected in the output filename.

Typical usage:

    kepler -c append -o ~/data/output ~/data/input/kplr001234567*.txt

where kplr001234567 is a unique object with only consecutive quarters.

### Slicer

Slicer is designed to take a converted dataset and cut it up into user-specified pieces. The length of these pieces are specified (in days) as the slice-ratio (-s). Slicer counts these days in terms of one day's worth of points, rather than one day in time. Therefore, if there is a gap in the middle of a slice, the time between the final and initial points in the slice will be more than one day. As the time gap between each point of long cadence data is roughly 0.02, there will be 50 points in one day's worth of LC data. if a half-day time gap were to lay in the middle of this slice, the total length of the slice would therefore be 1.5 days.

Slicer determines whether the data is long or short cadence by the filename, and bases the number of points in a slice from that. Users should note that the final slice will almost always be incomplete, and should account for this in their analyses.

The output filename indicates the length of the slices and the part\_number of that slice - a 90 day dataset split into 2-day slices will have 45 slices in parts from 0 to 44. Since it is often appended data that is sliced, such an example is presented below.

Typical usage:

    kepler -c slice -s 2 -o ~/data/output ~/data/output/kic01234567-appended_Q2.1-Q2.3_slc.


### Modulation Finder

Modulation finder seeks to identify variations in the frequency and amplitude of the maximum peak in a dataset's transform over time. The function of the program is to make a fourier transform of slices of data, find the highest peak in each one, and write the frequency and amplitude of that peak into an array. This array of peaks is built up over all slices, and then the frequencies and amplitudes are handled separately: each are plotted as a function of time (time is the mid-point of each slice), and a fourier transform of that is run for each to determine if there is a pattern in the variation of either frequency or amplitude with time.

Modulation finder automatically transforms the data within the Nyquist limit, by calculating the time-span of the slices and using half of that time as the upper frequency limit in the transform. The user must therefore be clever in selecting the correct slice size to suitably analyse the data - too short and the frequency of variation will be above the Nyquist; too long and there are too few slices for a meaningful transform.

The mid-point of each data slice is found automatically, and the sliced dataset is automatically sorted into part-order before other processes are implemented.

Typical usage:

    kepler -c find_mod ~/data/output/01234567_slices/kic01234567_CFlux_Q2.1-2.3_1d-slices-part*.txt

where the slices have been kept in a separate directory within the output directory.

The mean and standard deviation of both the frequencies and the amplitudes are written to the terminal; four .png files are created in ~/data/output.

### Detrender

The detrender is designed to work on converted data. It uses GSL to find a linear least-squares fit to the data, then subtracts that from the data. The output filename duplicates the input filename and adds "\_detrended" immediately before "\_{s/l}lc".

Typical usage:

    kepler -c detrend -o ~/data/output ~/data/output/filename.txt


### Phase Finder

Phase finder takes an input (typically from an Excel spreadsheet) containing a frequency ID, frequency, amplitude, calculated phase (float in range -pi to +pi), frequency combination, and calculated phase error. With that it computes relative phases and relative phase errors, and returns them as two additional columns in the output file. The output filename duplicates the input filename and adds "\_phazered" immediately before the file extension. Note that the column delimiter of the input file is expected to be "\t", and lends itself to spreadsheet columns copied into a text editor.

Typical usage:

    kepler -c find_phase -o ~/data/output ~/data/output/filename.txt

The relative phases returned will be folded on multiples of 2 pi. By plotting a scatter diagram of the relative phase against frequency for the combination frequencies, one should see stripes of points if there is a correlated relationship. It is recommended to unfold these manually by shifting the points by multiples of 2 pi so that they form a straight line. Once the line is straight, albeit perhaps with a few outliers, the "Fitter" program is recommended to improve the fit.

### Fitter

Fitter takes a series of x and y values, fits a linear trend to them, and then tries to improve the fit by moving points up and down the y-axis. It does this by computing the residual from the fit for that point (y - (m * x + c)), and adding or subtracting 2pi if the residual is < -pi, > +pi respectively.

Typical usage:

    kepler -c improve_fit -o ~/data/output -f ~/data/output/filename.txt

Fitter may need to be run more than once to converge on the best fit, so the force overwrite command "-f" has been implemented in the above typical usage example. The output from the first iteration will need to be used as the input for the second iteration in this case - such a re-iterative procedure is not yet automated.

### Inspector

Inspector provides information on the time span of Kepler observations and the duty cycle over that period. It can take single or multiple files, and will order them into season order. It appends the files to single file to calculate the time span and duty cycle, but doesn't save this file. It puts the results to the terminal instead.

Typical usage:

    kepler -c inspect -o ~/data/output ~/data/output/filename_Q*.txt

Although it may well be possible to incorporate this feature into the catalogue making process, the generic application of Inspector would not be appropriate because of the different cadences available and the occasional wish to omit poor data from such statistics.

### Matcher

The purpose of Matcher is to take a list of Fourier information (i.e. kic\_number, season, peak amplitude, peak frequency, grass level) and an observation index, and to port that Fourier information over to the observation index. The program thus takes two files containing "fourier\_information" and "observation\_index" in the filename (in any order). Matching takes place by kic\_number and season.

Typical usage:

    kepler -c match_obs -o ~/data/output ~/data/output/some_fourier_information.txt ~/data/output/corresponding_observation_index.txt

Observations for which corresponding Fourier information was not found are written to the terminal. Matcher produces matched\_table.txt.

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

Copyright (c) 2011,2012,2013 Simon Murphy, Ben Langfeld. MIT licence (see LICENSE for details).

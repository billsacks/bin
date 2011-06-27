# awk script used by ncreldiffs
#
# This script outputs the lines of the input file (which is intended to
# be the difference file from ncreldiffs), along with:
#  - the average_abs column from the magnitudes file
#  - each data column in the input file (i.e., the difference file)
#    divided by the average_abs column from the magnitudes file: i.e.,
#    the relative differences

# Requires the following variables to be set (using -v variable=value):
#  - first_data_col: index of first column in the input file that has
#    data (as opposed to header information like the variable name and
#    level)
#  - magfile: name of the magnitudes file from ncreldiffs
#    - We think of this file as containing the magnitudes of the "control" run;
#      these are the magnitudes used to calculate relative differences
#  - expt_magfile: name of the expt_magnitudes file from ncreldiffs
#  - abscol: index of the average_abs column in the magnitudes files (both magfile and expt_magfile)

# Header row:
NR==1 {
    # First print existing header row:
    printf "%s", $0
    # Then print "Avg_Magnitude" & "Expt_Avg_Magnitude" headers:
    printf "%14s", "Avg_Magnitude"
    printf "%19s", "Expt_Avg_Magnitude"
    # Then print each element of the existing header row followed by "_Rel"
    for (i=first_data_col; i<=NF; i++) 
	printf "%12s_Rel", $i
    printf "\n"

    # Get & discard header line from the magfile & expt_magfile:
    getline mag_summary < magfile
    getline expt_mag_summary < expt_magfile
}

# Data rows:
NR>1 {
    # First print existing data:
    printf "%s", $0

    # Then print the average magnitude, from the magfile:
    # (This value is the one used for calculating relative differences)
    getline mag_summary < magfile
    split(mag_summary, mag_summary_arr)
    avgmag = mag_summary_arr[abscol]
    printf "%14s", avgmag

    #... and from the expt_magfile:
    getline expt_mag_summary < expt_magfile
    split(expt_mag_summary, expt_mag_summary_arr)
    expt_avgmag = expt_mag_summary_arr[abscol]
    printf "%19s", expt_avgmag

    # Then calculate and print the relative values
    # Note that 'i' refers to the column number, and '$i' refers to the data in that column
    for (i=first_data_col; i<=NF; i++) {
	if (avgmag == 0)
	    printf "%16s", "NA"
	else  {
	    relval = $i/avgmag
	    printf "%16.7g", relval
	}
    }

    printf "\n"
}


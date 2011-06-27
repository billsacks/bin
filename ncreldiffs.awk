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
#  - abscol: index of the average_abs column in the magnitudes file
#  - summary_outfile: name of file to which we output a short summary,
#    giving the mins & maxes over each of the relative difference
#    columns

# Header row:
NR==1 {
    # First print existing header row:
    printf "%s", $0
    # Then print "Avg_Magnitude"
    printf "%14s", "Avg_Magnitude"
    # Then print each element of the existing header row followed by "_Rel"
    for (i=first_data_col; i<=NF; i++) 
	printf "%12s_Rel", $i
    printf "\n"

    # Save the column names & number of columns for later use (in the END block):
    split($0, colnames)
    ncols = NF

    # Get & discard header line from the magfile:
    getline mag_summary < magfile
}

# Data rows:
NR>1 {
    # First print existing data:
    printf "%s", $0

    # Then print the average magnitude, from the magfile:
    getline mag_summary < magfile
    split(mag_summary, mag_summary_arr)
    avgmag = mag_summary_arr[abscol]
    printf "%14s", avgmag

    # Then calculate and print the relative values;
    # also track min & max of each relative value column
    # Note that 'i' refers to the column number, and '$i' refers to the data in that column
    for (i=first_data_col; i<=NF; i++) {
	if (avgmag == 0)
	    printf "%16s", "NA"
	else  {
	    relval = $i/avgmag
	    printf "%16.7g", relval

	    # Track mins & maxes
	    if (i in mins) {  # we have an existing min for this column
		if (relval < mins[i])
		    mins[i] = relval
	    }
	    else  # no min yet for this column
		mins[i] = relval

	    if (i in maxes) {  # we have an existing max for this column
		if (relval > maxes[i])
		    maxes[i] = relval
	    }
	    else  # no max yet for this column
		maxes[i] = relval
	}
    }

    printf "\n"
}

# Print mins & maxes to <summary_outfile>:
END {
    # Print header:
    printf "%9s", " " > summary_outfile
    for (i=first_data_col; i<=ncols; i++) 
	printf("%12s_Rel", colnames[i]) > summary_outfile
    printf("\n") > summary_outfile

    # Print minimums:
    printf("MINIMUMS:") > summary_outfile
    for (i=first_data_col; i<=ncols; i++)
	printf("%16.7g", mins[i]) > summary_outfile
    printf("\n") > summary_outfile

    # Print maximums:
    printf("MAXIMUMS:") > summary_outfile
    for (i=first_data_col; i<=ncols; i++)
	printf("%16.7g", maxes[i]) > summary_outfile
    printf("\n") > summary_outfile

}    
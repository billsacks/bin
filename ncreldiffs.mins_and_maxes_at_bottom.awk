# awk script used by ncreldiffs
# This script outputs the lines of the difference file, along with:
#  - the abs_average column from the magnitudes file
#  - each column in the difference file divided by the abs_average column from the magnitudes file

# Requires the following variables to be set on the command-line:
#  - first_data_col
#  - magfile
#  - abscol

# Header row:
NR==1 {
    # First print existing header row:
    printf "%s", $0
    # Then print "Avg_Magnitude"
    printf "%14s", "Avg_Magnitude"
    # Then print each element of the existing header row followed by "_Rel"
    for (i=first_data_col; i<=NF; i++) printf "%12s_Rel", $i
    printf "\n"

    # For later use: determine the line length of the original data plus the Avg_Magnitude
    line_length_before_rels = (length $0) + 14

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

# Print mins & maxes:
END {
    # Create a format string for printing "MINIMUMS:" and "MAXIMUMS:" with the proper field width:
    # e.g., if line_length_before_rels is 100, this will be "%-100s"
    leading_fmt = sprintf("%%-%ds", line_length_before_rels)

    # Print minimums:
    printf(leading_fmt, "MINIMUMS:")
    for (i=first_data_col; i<=NF; i++)
	printf("%16.7g", mins[i])
    printf("\n")

    # Print maximums:
    printf(leading_fmt, "MAXIMUMS:")
    # Relative data maximums:
    for (i=first_data_col; i<=NF; i++)
	printf("%16.7g", maxes[i])

    printf("\n")

}    
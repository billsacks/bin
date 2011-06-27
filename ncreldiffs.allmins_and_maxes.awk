# awk script used by ncreldiffs
# This script outputs the lines of the difference file, along with:
#  - the abs_average column from the magnitudes file
#  - each column in the difference file divided by the abs_average column from the magnitudes file

# Requires the following variables to be set on the command-line:
#  - first_data_col
#  - dat_field_width
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

    # For later use: determine the length of the leading (non-data) fields:
    line_length = length $0
    data_length = dat_field_width * (NF - first_data_col + 1)
    leading_length = line_length - data_length

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
    # also track min & max of each column
    # Note that 'i' refers to the column number, and '$i' refers to the data in that column
    for (i=first_data_col; i<=NF; i++) {

	# Track mins & maxes for data columns:
	if (i in mins) {  # we have an existing min for this data column
	    if ($i < mins[i])
		mins[i] = $i
	}
	else  # no min yet for this data column
	    mins[i] = $i

	if (i in maxes) {  # we have an existing max for this data column
	    if ($i > maxes[i])
		maxes[i] = $i
	}
	else  # no max yet for this data column
	    maxes[i] = $i


	# Calculate & print relative value:
	if (avgmag == 0)
	    printf "%16s", "NA"
	else  {
	    relval = $i/avgmag
	    printf "%16.7g", relval

	    # Track mins & maxes for relative values
	    if (i in relmins) {  # we have an existing min for this relative column
		if (relval < relmins[i])
		    relmins[i] = relval
	    }
	    else  # no min yet for this relative column
		relmins[i] = relval

	    if (i in relmaxes) {  # we have an existing max for this relative column
		if (relval > relmaxes[i])
		    relmaxes[i] = relval
	    }
	    else  # no max yet for this relative column
		relmaxes[i] = relval
	}
    }

    printf "\n"
}

# Print mins & maxes:
END {
    # Create a format string for printing "MINIMUMS:" and "MAXIMUMS:" with the proper field width:
    # e.g., if leading_length is 40, this will be "%-40s"
    leading_fmt = sprintf("%%-%ds", leading_length)
    # Create a format string for printing mins & maxes of data field:
    # e.g., if dat_field_width is 15, then this will be "%15.7g"
    data_fmt = sprintf("%%%d.7g", dat_field_width)

    # Print minimums:
    printf(leading_fmt, "MINIMUMS:")
    # Data minimums:
    for (i=first_data_col; i<=NF; i++)
	printf(data_fmt, mins[i])
    # Blanks in the Avg_Magnitude column:
    printf("%14s", " ")
    # Relative data minimums:
    for (i=first_data_col; i<=NF; i++)
	printf("%16.7g", relmins[i])
    printf("\n")

    # Print maximums:
    printf(leading_fmt, "MAXIMUMS:")
    # Data maximums:
    for (i=first_data_col; i<=NF; i++)
	printf(data_fmt, maxes[i])
    # Blanks in the Avg_Magnitude column:
    printf("%14s", " ")
    # Relative data maximums:
    for (i=first_data_col; i<=NF; i++)
	printf("%16.7g", relmaxes[i])

    printf("\n")

}    
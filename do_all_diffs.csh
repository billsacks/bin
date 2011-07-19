#! /usr/bin/tcsh -f

# Bill Sacks
# 4/16/07

# use ncea to compute seasonal and annual averages, given monthly files
# run this from within the directory containing the monthly files to average
# this replaces the older dodiff.csh and annualavg.csh

# Define all variables here
set controlbase = clm3.5-cam_control_agonly.cam2.h0
set casebase = clm3.5-cam_irrigation_agonly.cam2.h0
# yearsbasecase and yearsbasecontrol: if there are any prefixes before the year in either of the two sets of output files
set yearsbasecase = ""
set yearsbasecontrol = ""
# set years = "1998,1999,2000,2001,2002,2003,2004"
# set years = "0003,0004,0005,0006,0007,0008,0009,0010,0011,0012,0013,0014,0015,0016,0017,0018,0019,0020,0021,0022,0023,0024,0025,0026,0027,0028,0029"
set years = "0010,0011,0012,0013,0014,0015,0016,0017,0018,0019,0020,0021,0022,0023,0024,0025,0026,0027,0028,0029"
# set yearname = "1998-2004"
# set yearname = "0003-0029"
set yearname = "0010-0029"
# months and monthnames give the seasons over which we calculate averages
set all_months = ( "12,01,02" "03,04,05" "06,07,08" "09,10,11" "01,02,03,04,05,06,07,08,09,10,11,12" )
set all_monthnames = ( DJF MAM JJA SON ANNUAL )
# casevars: variables that exist in case but not in control: include in difference output by treating as implicitly 0 in control (i.e. copy value in case)
# set casevars = "QIRRIG"
set casevars = ""
# excludevars: variables that exist in case but not in control: exclude from difference output
set excludevars = ""
# directory in which output from this script will go:
set outputdir = $HOME/irrigation_output

# Shouldn't have to edit anything below this

# Error-check variables:
if ( ! -d $outputdir ) then
    echo "ERROR: $outputdir not a directory"
    exit 1
endif

# Compute additional variables:
# append casevars onto end of excludevars:
if ( $casevars != "" ) then
    if ( $excludevars != "" ) then
	set excludevars = "$excludevars,"
    endif
    set excludevars = "$excludevars$casevars"
endif

set i = 1
while ($i <= $#all_months )
    set months = $all_months[$i]
    set monthname = $all_monthnames[$i]
    
    echo ""
    echo "----------------------------------"
    echo ""
    echo "Months: $months"
    echo "Monthname: $monthname"

    echo "Using the following case files:"
    ls $casebase.$yearsbasecase{$years}-{$months}.nc

    echo "Using the following control files:"
    ls $controlbase.$yearsbasecontrol{$years}-{$months}.nc

    echo "Averaging case -> $casebase.$monthname.$yearname.nc"
    if ( -e $outputdir/$casebase.$monthname.$yearname.nc ) then
	echo $outputdir/$casebase.$monthname.$yearname.nc already exists
    else
	ncea $casebase.$yearsbasecase{$years}-{$months}.nc $outputdir/$casebase.$monthname.$yearname.nc
    endif

    echo "Averaging control -> $controlbase.$monthname.$yearname.nc"
    if ( -e $outputdir/$controlbase.$monthname.$yearname.nc ) then
	echo $outputdir/$controlbase.$monthname.$yearname.nc already exists
    else
	ncea $controlbase.$yearsbasecontrol{$years}-{$months}.nc $outputdir/$controlbase.$monthname.$yearname.nc
    endif

    if ( $excludevars != "" ) then
	echo "Removing rogue variables from $casebase.$monthname.$yearname.nc -> $casebase.$monthname.$yearname.exclude.nc:"
	echo $excludevars
	if ( -e $outputdir/$casebase.$monthname.$yearname.exclude.nc ) then
	    echo $outputdir/$casebase.$monthname.$yearname.exclude.nc already exists
	else
	    ncks -x -v $excludevars $outputdir/$casebase.$monthname.$yearname.nc $outputdir/$casebase.$monthname.$yearname.exclude.nc
	endif
	set caseext = exclude.nc
    else
	set caseext = nc
    endif

    echo "Differencing -> $casebase.$monthname.$yearname.diff.nc"
    if (-e $outputdir/$casebase.$monthname.$yearname.diff.nc ) then
	echo $outputdir/$casebase.$monthname.$yearname.diff.nc already exists
    else
	ncbo --op_typ=- $outputdir/$casebase.$monthname.$yearname.$caseext $outputdir/$controlbase.$monthname.$yearname.nc $outputdir/$casebase.$monthname.$yearname.diff.nc
	if ( $casevars != "" ) then
	    echo "Appending variables from case (implicitly assuming they're 0 in control):"
	    echo $casevars
	    echo 'It is normal for this command to generate many warning messages ("Overwriting global attribute..." and "Overwriting attribute...")'
	    ncks -A -v $casevars $outputdir/$casebase.$monthname.$yearname.nc $outputdir/$casebase.$monthname.$yearname.diff.nc
	endif
    endif

    if ( $excludevars != "" ) then
	echo "Cleaning up: removing $casebase.$monthname.$yearname.exclude.nc"
	rm $outputdir/$casebase.$monthname.$yearname.exclude.nc
    endif

    @ i++
end



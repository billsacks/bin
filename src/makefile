# **************************************************************************
# Makefile for various tools
# **************************************************************************

# Get configuration options (FC, OPT, R_PREC)
include makefile.config

# Set compiler options: sets (at least) the following variables:
# - FC77
# - FC90
# - LD
# - F77_OPTIONS
# - F90_OPTIONS
include ../makefile.common

# --------------------------------------------------------------------------
# Extra linker options specific to this program
# --------------------------------------------------------------------------

# (note that the syntax for this LD option is the same for all possible linkers)
LD_OPTIONS := $(LD_OPTIONS) -lnetcdf

# --------------------------------------------------------------------------
# Variables that make needs (specifying search path, etc.)
# --------------------------------------------------------------------------

# Path to search for prerequisites
VPATH = ../src ../tools ../netcdf_wrappers

# --------------------------------------------------------------------------
# Variables holding the names of all of the object files needed for pegasus:
# --------------------------------------------------------------------------

PEGASUS_OBJECTS = climate.o errorMod.o general_utils.o initial.o input.o io_shared.o main.o management.o nanMod.o netcdf4d.o output.o output_general.o parallel.o pegasus_data.o pegasus_utils.o pheno.o produce.o read_init.o soil.o stats.o typeMod.o veg_types.o vegetation.o netcdf.o typeSizes.o

# --------------------------------------------------------------------------
# Variables holding the names of all of the object files needed for miscellaneous tools:
# --------------------------------------------------------------------------

ASC2NC_OBJECTS = asc2nc.o typeMod.o errorMod.o general_utils.o netcdf4d.o netcdf.o typeSizes.o

MAKE_LAND_MASK_OBJECTS = make_land_mask.o merge_masks_mod.o typeMod.o errorMod.o general_utils.o netcdf4d.o netcdf.o typeSizes.o

NC_FREQS_OBJECTS = nc_freqs.o general_utils.o netcdf4d.o typeMod.o errorMod.o netcdf.o typeSizes.o

# --------------------------------------------------------------------------
# Rules for compilation & linkage
# --------------------------------------------------------------------------

# define implicit rule to compile .f files: we can make a .o file from a .f file by running FC77
%.o : %.f
	$(FC77) $(F77_OPTIONS) $(MY_F_OPTIONS) $(INCLUDES) -c $<
# $< stands for the source file

# and define the same rule for compiling .F files:
%.o : %.F
	$(FC77) $(F77_OPTIONS) $(MY_F_OPTIONS) $(INCLUDES) -c $<

# define implicit rule to compile .f90 files: we can make a .o file from a .f90 file by running FC90
%.o : %.f90
	$(FC90) $(F90_OPTIONS) $(MY_F_OPTIONS) $(INCLUDES) -c $<

# and define the same rule for compiling .F90 files:
%.o : %.F90
	$(FC90) $(F90_OPTIONS) $(MY_F_OPTIONS) $(INCLUDES) -c $<

pegasus.x: $(PEGASUS_OBJECTS)
	$(LD) $(PEGASUS_OBJECTS) $(LD_OPTIONS) $(MY_LD_OPTIONS) $(LIBS) -o pegasus.x

asc2nc: $(ASC2NC_OBJECTS)
	$(LD) $(ASC2NC_OBJECTS) $(LD_OPTIONS) $(MY_LD_OPTIONS) $(LIBS) -o asc2nc

make_land_mask: $(MAKE_LAND_MASK_OBJECTS)
	$(LD) $(MAKE_LAND_MASK_OBJECTS) $(LD_OPTIONS) $(MY_LD_OPTIONS) $(LIBS) -o make_land_mask

nc_freqs: $(NC_FREQS_OBJECTS)
	$(LD) $(NC_FREQS_OBJECTS) $(LD_OPTIONS) $(MY_LD_OPTIONS) $(LIBS) -o nc_freqs

tools: asc2nc make_land_mask nc_freqs

all: pegasus.x tools

# define rule to create output.f90 auto-magically (using code generation script)
output.f90 : replace_output_templates output_list output_template.f90
	$(join $(dir $+), $(notdir $+)) output.f90
# $+ stands for all prerequisites, in order, including their relative path
# $(dir $+) gets a list of all directories, $(notdir $+) gets the file names (without directories),
#  and join joins them together, to get a list of all prerequisetes with their relative path
# The difference between this complex expression and just doing $+ output.f90
#  is that the complex way of doing it adds an explicit ./ to things that are here,
#  which is necessary if the user does not have . in their path


# --------------------------------------------------------------------------
# Dependencies: These are built automatically using the sfmakedepend tool
# --------------------------------------------------------------------------

# find all source files (look in the directories given in VPATH for files ending in .f, .F, .f90 and .F90)
FSRCS := $(foreach DIR, $(VPATH),$(wildcard $(DIR)/*.[fF] $(DIR)/*.[fF]90))

MAKEFILE_INC = makefile.inc
# In the following, the 'patsubst' inserts '-I ' before each item in the VPATH (which allows us to find 'included' files in any directory in the VPATH);
#  the 'subst' inserts a space after each '-I' in the INCLUDES variable (which allows us to find 'included' files in any directory in INCLUDES)
F_makedepend = ./sfmakedepend --file - --longpath --template _template $(patsubst %,-I %,$(VPATH)) $(subst -I,-I ,$(INCLUDES))

# we re-build the depencies file if any source file changes
depend $(MAKEFILE_INC): $(FSRCS)
	$(F_makedepend) $(FSRCS) > $(MAKEFILE_INC)

include $(MAKEFILE_INC)

# --------------------------------------------------------------------------
# "Phony" targets (clean, etc.):
# --------------------------------------------------------------------------

clean:
	rm -fv *.o *.mod output.f90 $(MAKEFILE_INC)

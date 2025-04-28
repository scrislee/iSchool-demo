### Descriptive statistics ###

### Getting started --------------------------
# Clean up the working environment by restarting R (on Mac shift command 0)
rm(list = ls())

# Verify working directory on personal machine ends in usfSTEM-FLC
# E.g., "/Users/sarahclee/Documents/Analyses/usfSTEM-FLC"
# getwd()

# Specify required packages
packages <- c("tidyverse")

# Check if required packages are installed and load or install & load all
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)

# Check for updates
tidyverse_update()
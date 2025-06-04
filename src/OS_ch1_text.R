#### OpenIntro Statistics Chapter 1 ####
## Getting started --------------------------
# Clean up the working environment by restarting R (on Mac shift command 0)
rm(list = ls())
# In RStudio, Environment tab should show Environment is empty

# Specify required packages
packages <- c("tidyverse", "openintro", "infer", "palmerpenguins", "ggthemes")

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

## 1.1 Case study: using stents to prevent strokes ---------------
# Read in stent data
stent30 <- read_csv("data/stent30.csv")

# Glance at data
stent30
glimpse(stent30)
summary(stent30)



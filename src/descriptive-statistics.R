### Descriptive statistics ###

### Getting started --------------------------
# Clean up the working environment by restarting R (on Mac shift command 0)
rm(list = ls())

# Verify working directory on personal machine ends in iSchool-demo
# E.g., "/Users/sarahclee/Documents/Analyses/iSchool-demo"
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

# Read in data
data <- read_csv("data/TCB-Brew-Data.csv",
                          col_types = cols(batch_start = col_datetime(format = "%Y-%m-%d %H:%M:%S")))

# Quick look data
summary(data)

# Summary statistics
summ_beer <- data %>%
group_by(brand) %>%
summarise(
mean = mean(mash_pH),
median = median(mash_pH),
#IQR = IQR(mash_pH),
sd = sd(mash_pH),
var = var(mash_pH)
 )

# Plot mash_pH as a histograms
ggplot(data)+
  geom_histogram(aes(knockout_pH), binwidth = 0.10)+
  facet_wrap(~brand)

# Hefeweisen only

bba_data <- data %>%
  filter(brand=="bba")
ggplot(bba_data)+
  geom_histogram(aes(knockout_pH), binwidth = 0.05)

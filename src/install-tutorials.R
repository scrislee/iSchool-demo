#### Getting Started ####

# Clean up the working environment by restarting R (on Mac shift command 0)
rm(list = ls())
# In RStudio, Environment tab should show Environment is empty

# Install the “remotes” package 
install.packages("remotes")

# Install the "AppliedStatsInteractive" package 
# Note that this will take some time, so chill out until you receive a DONE
# message in the console
# This will probably be from scrislee not agmath
# remotes::install_github("scrislee/AppliedStatsInteractive")
remotes::install_github("agmath/AppliedStatsInteractive")

# Install Colin Rundel's learnrhash package
remotes::install_github("rundel/learnrhash")

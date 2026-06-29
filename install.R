# -----------------------------------------------------------------------
# install.R  -  Rank_Pref_Replication
# R version: 4.x
#
# Usage:
#   source("install.R")          # quick install
#   # ...or for full reproducibility:
#   install.packages("renv"); renv::restore()
# -----------------------------------------------------------------------

pkgs <- c(
  # Data manipulation
  "dplyr",
  "readr",
  "tidyr",

  # Plotting
  "ggplot2",
  "scales",
  "RColorBrewer",
  "Hmisc",          # stat_summary(fun.data = "mean_cl_normal") in Figures 1, 2

  # Markdown / table formatting
  "knitr"           # knitr::kable() for the tables_2_3 markdown report
)

new_pkgs <- pkgs[!(pkgs %in% installed.packages()[, "Package"])]
if (length(new_pkgs) > 0) install.packages(new_pkgs)
message("All packages installed.")

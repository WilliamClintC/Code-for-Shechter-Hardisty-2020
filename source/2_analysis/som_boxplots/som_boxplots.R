# ===========================================================================
# Figures SOM.2, SOM.3, SOM.4  --  Box plots of utility at each rank per study
#
# Style (Excel-style boxplots):
#   - medium blue fill (#5B9BD5), thicker box outline
#   - thin black whiskers, thin black median
#   - outliers hidden
#   - x-axis labels "Rank 5", "Rank 4", ... (rank order: best on right)
#   - centered title "Study N" above plot
#   - horizontal-only light gridlines, no panel border
#
# Inputs:  data/1_derived/competition/long_utils.csv
# Output:  output/2_analysis/figures/figure_som{2,3,4}_boxplots_study{1,2,3}.{pdf,png}
# ===========================================================================

source("source/lib/setup_libs.R")
suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(readr)
})

find_root <- function() {
  d <- getwd()
  while (!file.exists(file.path(d, "run_all.py"))) {
    pd <- dirname(d)
    if (pd == d) stop("Could not find project root (run_all.py)")
    d <- pd
  }
  d
}
ROOT    <- find_root()
FIG_DIR <- file.path(ROOT, "output", "2_analysis", "figures")
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)
source(file.path(ROOT, "source", "lib", "theme_healy.R"))

long <- read_csv(file.path(ROOT, "data", "1_derived", "competition", "long_utils.csv"),
                 show_col_types = FALSE)

specs <- list(
  list(study = "exp72", title = "Study 1", file = "figure_som2_boxplots_study1",
       elicited = c(2, 3, 4, 5)),
  list(study = "exp73", title = "Study 2", file = "figure_som3_boxplots_study2",
       elicited = c(2, 3, 4, 5)),
  list(study = "exp58", title = "Study 3", file = "figure_som4_boxplots_study3",
       elicited = c(2, 3, 5, 8, 9))
)

PAPER_BLUE        <- "#5B9BD5"
PAPER_BLUE_STROKE <- "#41719C"

for (spec in specs) {
  sub <- long %>%
    filter(study == spec$study, rank %in% spec$elicited) %>%
    mutate(rank_lab = paste("Rank", rank),
           rank_lab = factor(rank_lab,
                             levels = paste("Rank", rev(sort(unique(rank))))))

  p <- ggplot(sub, aes(x = rank_lab, y = utility)) +
    geom_boxplot(fill = PAPER_BLUE, color = PAPER_BLUE_STROKE,
                 outlier.shape = NA,                 # hide outliers
                 width = 0.55, linewidth = 0.4) +
    scale_y_continuous(breaks = seq(0, 1, 0.2), limits = c(0, 1), expand = c(0, 0)) +
    labs(x = NULL, y = "Utility", title = spec$title) +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor   = element_blank(),
          axis.title.y = element_text(face = "bold"),
          plot.title = element_text(hjust = 0.5, face = "bold", size = 12))

  healy_save(file.path(FIG_DIR, paste0(spec$file, ".pdf")), p, width = 6.0, height = 4.0)
  healy_save(file.path(FIG_DIR, paste0(spec$file, ".png")), p, width = 6.0, height = 4.0)
  cat("wrote output/2_analysis/figures/", spec$file, ".{pdf,png}\n", sep = "")
}

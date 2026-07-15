# ===========================================================================
# Figure SOM.1  --  Average utility by rank, Study 3 (10-person)
#
# Style: vertical bar chart with 95% CI whiskers.
# Ranks 4, 6, 7 are not elicited; shown as gaps on the x-axis.
# X-axis runs from rank 10 (last) on the left to rank 1 (first) on the right.
#
# Input:  data/1_derived/competition/long_utils.csv
# Output: output/2_analysis/figures/figure_som1_utility_study3.{pdf,png}
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

s3 <- long %>%
  filter(study == "exp58") %>%
  group_by(rank) %>%
  summarise(
    n      = n(),
    mean_U = mean(utility),
    se     = sd(utility) / sqrt(n),
    ci_lo  = mean_U - qt(0.975, df = n - 1) * se,
    ci_hi  = mean_U + qt(0.975, df = n - 1) * se,
    .groups = "drop"
  )

# Include rank 1 and 10 anchors (no CI, they are point masses at 1 and 0)
s3_plot <- s3 %>% mutate(ci_lo = ifelse(is.na(se), mean_U, ci_lo),
                          ci_hi = ifelse(is.na(se), mean_U, ci_hi))

p <- ggplot(s3_plot, aes(x = factor(rank, levels = 10:1), y = mean_U)) +
  geom_col(fill = "#4F81BD", width = 0.7) +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.2, linewidth = 0.4) +
  scale_y_continuous(breaks = seq(0, 1, 0.2), limits = c(0, 1.05), expand = c(0, 0)) +
  scale_x_discrete(drop = FALSE) +  # keep all 10 ranks on the axis
  labs(x = "Rank", y = "Utility", title = "Average Utility vs. Rank") +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor   = element_blank(),
        plot.title = element_text(hjust = 0.5, face = "plain", size = 13))

healy_save(file.path(FIG_DIR, "figure_som1_utility_study3.pdf"), p, width = 6.5, height = 4.0)
healy_save(file.path(FIG_DIR, "figure_som1_utility_study3.png"), p, width = 6.5, height = 4.0)
cat("wrote output/2_analysis/figures/figure_som1_utility_study3.{pdf,png}\n")

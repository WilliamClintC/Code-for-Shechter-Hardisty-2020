# ===========================================================================
# Figure 1  --  Average utility by rank, Studies 1 + 2
#
# Style:
#   - red for Study 1, navy/blue for Study 2 (ColorBrewer Set1 colors 1 and 2)
#   - faint per-participant spaghetti, jittered
#   - solid mean line + 95% CI point-range marker at each rank
#   - x-axis reversed: rank 6 on the left, rank 1 on the right
#   - legend inside the plot at upper-left
#
# Input:  data/1_derived/competition/long_utils.csv
# Output: output/2_analysis/figures/figure1_utility_by_rank.{pdf,png}
# ===========================================================================

source("source/lib/setup_libs.R")
suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(readr)
  library(Hmisc)
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

dfl <- long %>%
  filter(n_ranks == 6) %>%
  mutate(study = recode(study, "exp72" = "Study 1", "exp73" = "Study 2"))

jitter <- position_jitter(width = 0.05, height = 0.01)

p <- ggplot(dfl, aes(x = rank, y = utility,
                     color = study, linetype = study, group = pid)) +
  geom_hline(yintercept = 0, color = "grey80", linewidth = 0.3) +
  # per-participant spaghetti
  geom_line(alpha = 0.02, position = jitter) +
  # mean line per study
  stat_summary(aes(group = study), fun.data = "mean_cl_normal",
               geom = "line", linewidth = 0.9) +
  # mean point + 95% CI marker
  stat_summary(aes(group = study, shape = study), fun.data = "mean_cl_normal",
               size = 0.6, stroke = 0.8, geom = "pointrange") +
  scale_color_brewer(palette = "Set1") +
  scale_shape_manual(values = c("Study 1" = 18, "Study 2" = 17)) +  # diamond, triangle
  scale_x_reverse(breaks = 1:6) +
  scale_y_continuous(breaks = seq(0, 1, 0.2), limits = c(0, 1)) +
  labs(x = "Rank Number", y = "Utility") +
  guides(color = guide_legend("Study"),
         linetype = guide_legend("Study"),
         shape = guide_legend("Study")) +
  theme(legend.position = c(0.10, 0.92),
        legend.background = element_blank(),
        legend.title = element_blank(),
        legend.text = element_text(size = 11),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

healy_save(file.path(FIG_DIR, "figure1_utility_by_rank.pdf"), p, width = 6.5, height = 4.5)
healy_save(file.path(FIG_DIR, "figure1_utility_by_rank.png"), p, width = 6.5, height = 4.5)
cat("wrote output/2_analysis/figures/figure1_utility_by_rank.{pdf,png}\n")

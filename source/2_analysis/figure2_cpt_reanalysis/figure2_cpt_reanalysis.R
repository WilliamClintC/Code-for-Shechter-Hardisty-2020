# ===========================================================================
# Figure 2  --  EUT vs CPT utility curves for Study 1
#
# Style:
#   - 4 solid lines (no point markers), no jitter
#   - Order in legend: EUT, CPT β=.60, CPT β=.74, CPT β=.88
#   - Colors: blue / grey / orange / yellow
#   - x-axis reversed (rank 6 on left, rank 1 on right)
#   - legend at the bottom, no plot border
# ===========================================================================

source("source/lib/setup_libs.R")
suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
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
TBL_DIR <- file.path(ROOT, "output", "2_analysis", "tables")
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)
source(file.path(ROOT, "source", "lib", "theme_healy.R"))

wide   <- read_csv(file.path(ROOT, "data", "1_derived", "competition", "wide_clean.csv"),
                   show_col_types = FALSE)
study1 <- wide %>% filter(study == "exp72")

# Prelec (1998) one-parameter probability-weighting function w(p) = exp(-(-ln p)^beta).
# This is the CPT reanalysis: the elicited indifference-probability values are treated as probabilities
# and re-weighted, so the plotted CPT curves show what the utilities would look
# like if respondents were weighting probabilities a la cumulative prospect theory
# rather than valuing them linearly (EUT). pmax(p, 1e-12) guards log(0); the
# endpoints p in {0, 1} are pinned to {0, 1} exactly.
prelec <- function(p, beta) {
  out <- exp(-((-log(pmax(p, 1e-12)))^beta))
  out[p == 0] <- 0
  out[p == 1] <- 1
  out
}

BETAS  <- c(0.60, 0.74, 0.88)
RANKCOL <- c("u1", "u2", "u3", "u4", "u5", "u6")

long_eut <- study1 %>%
  select(pid, all_of(RANKCOL)) %>%
  pivot_longer(cols = all_of(RANKCOL), names_to = "rank", values_to = "U") %>%
  mutate(rank = as.integer(sub("u", "", rank)), valuation = "EUT")

long_cpt <- bind_rows(lapply(BETAS, function(b) {
  study1 %>%
    select(pid, all_of(RANKCOL)) %>%
    pivot_longer(cols = all_of(RANKCOL), names_to = "rank", values_to = "p") %>%
    mutate(rank = as.integer(sub("u", "", rank)),
           U = prelec(p, beta = b),
           valuation = sprintf("CPT, Beta = .%02d", round(b * 100)))
})) %>% select(pid, rank, U, valuation)

long_all <- bind_rows(long_eut, long_cpt)
long_all$valuation <- factor(long_all$valuation,
                             levels = c("EUT", "CPT, Beta = .60",
                                        "CPT, Beta = .74", "CPT, Beta = .88"))

# Pre-aggregate so we plot one solid line per valuation (no markers).
agg <- long_all %>%
  group_by(valuation, rank) %>%
  summarise(mean_U = mean(U), .groups = "drop")

paper_palette <- c("EUT"             = "#1F497D",   # dark blue
                   "CPT, Beta = .60" = "#A6A6A6",   # grey
                   "CPT, Beta = .74" = "#E46C0A",   # orange
                   "CPT, Beta = .88" = "#FFC000")   # yellow

p <- ggplot(agg, aes(x = rank, y = mean_U, color = valuation, group = valuation)) +
  geom_hline(yintercept = 0, color = "grey85", linewidth = 0.3) +
  geom_line(linewidth = 1.0) +
  scale_color_manual(values = paper_palette) +
  scale_x_reverse(breaks = 1:6) +
  scale_y_continuous(breaks = seq(0, 1, 0.2), limits = c(0, 1), expand = c(0, 0)) +
  labs(x = "Rank", y = "Utility") +
  guides(color = guide_legend(nrow = 2)) +
  theme(legend.position = "bottom",
        legend.title = element_blank(),
        legend.text = element_text(size = 10),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

healy_save(file.path(FIG_DIR, "figure2_cpt_reanalysis.pdf"), p, width = 6.5, height = 4.5)
healy_save(file.path(FIG_DIR, "figure2_cpt_reanalysis.png"), p, width = 6.5, height = 4.5)

# Also save the per-rank mean utilities table
write.csv(tidyr::pivot_wider(agg, names_from = rank, values_from = mean_U,
                             names_prefix = "rank"),
          file.path(TBL_DIR, "figure2_means_eut_vs_cpt.csv"), row.names = FALSE)
cat("wrote output/2_analysis/figures/figure2_cpt_reanalysis.{pdf,png}\n")

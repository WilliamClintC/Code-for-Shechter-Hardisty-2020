# ===========================================================================
# Tables 2, 3, SOM.2, SOM.3  --  Proportions and magnitudes
#
# Table 2     : Studies 1, 2: % participants TRUE on H1, H2a, H2b, H4 with 95% CI.
# Table SOM.2 : Same for Study 3 (10-rank).
# Table 3     : Studies 1, 2: mean U(2) - U(5) and (U(1)-U(2)) - (U(5)-U(6)),
#               with 95% CI, paired-t, and Cohen's d.
# Table SOM.3 : Same for Study 3 (using U(9), U(10) anchors).
#
# Input:  data/1_derived/competition/wide_clean.csv
# Output: output/2_analysis/tables/table{2,3,som2,som3}.csv
#         output/2_analysis/tables/tables_2_3_combined.md
# ===========================================================================

source("source/lib/setup_libs.R")
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

# Find project root by walking up to run_all.py
find_root <- function() {
  d <- getwd()
  while (!file.exists(file.path(d, "run_all.py"))) {
    pd <- dirname(d)
    if (pd == d) stop("Could not find project root (run_all.py)")
    d <- pd
  }
  d
}
ROOT   <- find_root()
TABLES <- file.path(ROOT, "output", "2_analysis", "tables")
dir.create(TABLES, recursive = TRUE, showWarnings = FALSE)

wide <- read_csv(file.path(ROOT, "data", "1_derived", "competition", "wide_clean.csv"),
                 show_col_types = FALSE)

STUDIES <- c("exp72" = "Study 1", "exp73" = "Study 2", "exp58" = "Study 3")

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
prop_ci <- function(x) {
  # Wilson 95% CI; matches prop.test default.
  x <- x[!is.na(x)]
  if (length(x) == 0) return(c(mean = NA, lo = NA, hi = NA))
  pt <- prop.test(sum(x), length(x), conf.level = 0.95, correct = FALSE)
  c(mean = unname(pt$estimate), lo = pt$conf.int[1], hi = pt$conf.int[2])
}

ci_t <- function(x) {
  # 95% t-interval for the mean.
  x <- x[!is.na(x)]
  n <- length(x); m <- mean(x); se <- sd(x) / sqrt(n)
  h <- qt(0.975, df = n - 1) * se
  c(mean = m, lo = m - h, hi = m + h, n = n)
}

cohen_d_one <- function(x) {
  # Cohen's d for one-sample (vs zero) = mean / sd. Paired t equivalence.
  x <- x[!is.na(x)]
  mean(x) / sd(x)
}

# ---------------------------------------------------------------------------
# Table 2 / SOM.2  --  proportions
# ---------------------------------------------------------------------------
table2_rows <- list()
for (study in names(STUDIES)) {
  sub <- wide[wide$study == study, ]
  for (h in c("H1", "H2a", "H2b", "H4")) {
    ci <- prop_ci(sub[[h]])
    table2_rows[[length(table2_rows) + 1]] <- data.frame(
      study     = STUDIES[study],
      indicator = h,
      n         = sum(!is.na(sub[[h]])),
      pct       = round(ci["mean"] * 100, 1),
      ci_lo     = round(ci["lo"]   * 100, 1),
      ci_hi     = round(ci["hi"]   * 100, 1),
      row.names = NULL
    )
  }
}
table2 <- do.call(rbind, table2_rows)
cat("\n=== Table 2 / SOM.2 - Proportions (% TRUE, 95% CI) ===\n")
print(table2, row.names = FALSE)

# Wide layout: rows = study, cols = indicator
table2_wide <- table2 %>%
  mutate(pct_ci = sprintf("%.1f%% [%.1f, %.1f]", pct, ci_lo, ci_hi)) %>%
  select(study, indicator, pct_ci) %>%
  tidyr::pivot_wider(names_from = indicator, values_from = pct_ci)
cat("\n=== Wide layout ===\n")
print(as.data.frame(table2_wide), row.names = FALSE)

# Studies 1+2 = Table 2; Study 3 = SOM.2
write.csv(table2_wide[table2_wide$study %in% c("Study 1", "Study 2"), ],
          file.path(TABLES, "table2_proportions.csv"), row.names = FALSE)
write.csv(table2_wide[table2_wide$study == "Study 3", ],
          file.path(TABLES, "som2_proportions_study3.csv"), row.names = FALSE)
write.csv(table2, file.path(TABLES, "table2_proportions_long.csv"), row.names = FALSE)

# ---------------------------------------------------------------------------
# Table 3 / SOM.3  --  magnitudes
# ---------------------------------------------------------------------------
table3_rows <- list()
for (study in names(STUDIES)) {
  sub <- wide[wide$study == study, ]
  n_ranks <- sub$n_ranks[1]
  if (n_ranks == 6) {
    diff1 <- sub$u2 - sub$u5                          # U(2) - U(second-to-last)
    diff2 <- (sub$u1 - sub$u2) - (sub$u5 - sub$u6)    # drop-from-1 - drop-into-last
    lab1 <- "U(2) - U(5)"
    lab2 <- "[U(1)-U(2)] - [U(5)-U(6)]"
  } else {
    diff1 <- sub$u2 - sub$u9
    diff2 <- (sub$u1 - sub$u2) - (sub$u9 - sub$u10)
    lab1 <- "U(2) - U(9)"
    lab2 <- "[U(1)-U(2)] - [U(9)-U(10)]"
  }
  for (info in list(list(name = lab1, x = diff1),
                    list(name = lab2, x = diff2))) {
    ci <- ci_t(info$x)
    tt <- t.test(info$x, mu = 0)
    table3_rows[[length(table3_rows) + 1]] <- data.frame(
      study   = STUDIES[study],
      measure = info$name,
      n       = ci["n"],
      mean    = round(ci["mean"], 3),
      ci_lo   = round(ci["lo"],   3),
      ci_hi   = round(ci["hi"],   3),
      t_stat  = round(unname(tt$statistic), 2),
      p_value = format.pval(tt$p.value, digits = 2, eps = .001),
      cohen_d = round(cohen_d_one(info$x), 3),
      row.names = NULL
    )
  }
}
table3 <- do.call(rbind, table3_rows)
cat("\n=== Table 3 / SOM.3 - Magnitudes (paired t, Cohen's d) ===\n")
print(table3, row.names = FALSE)

write.csv(table3[table3$study %in% c("Study 1", "Study 2"), ],
          file.path(TABLES, "table3_magnitudes.csv"), row.names = FALSE)
write.csv(table3[table3$study == "Study 3", ],
          file.path(TABLES, "som3_magnitudes_study3.csv"), row.names = FALSE)

# ---------------------------------------------------------------------------
# Combined markdown summary
# ---------------------------------------------------------------------------
md_lines <- c(
  "# Tables 2, 3 (and SOM.2, SOM.3)",
  "",
  "## Table 2 / SOM.2: Proportion of participants satisfying each hypothesis (95% CI)",
  "",
  knitr::kable(table2_wide, format = "pipe"),
  "",
  "## Table 3 / SOM.3: Mean within-subject utility differences (paired t-test, Cohen's d)",
  "",
  knitr::kable(table3, format = "pipe"),
  ""
)
writeLines(md_lines, file.path(TABLES, "tables_2_3_combined.md"))

cat("\nwrote:\n")
cat("  ", file.path("output/2_analysis/tables", "table2_proportions.csv"), "\n")
cat("  ", file.path("output/2_analysis/tables", "som2_proportions_study3.csv"), "\n")
cat("  ", file.path("output/2_analysis/tables", "table3_magnitudes.csv"), "\n")
cat("  ", file.path("output/2_analysis/tables", "som3_magnitudes_study3.csv"), "\n")
cat("  ", file.path("output/2_analysis/tables", "tables_2_3_combined.md"), "\n")

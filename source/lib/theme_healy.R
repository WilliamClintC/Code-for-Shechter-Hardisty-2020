# ===========================================================================
# theme_healy.R  --  ggplot2 defaults following Kieran Healy's principles
#
# Based on:
#   Healy, Kieran. 2018. *Data Visualization: A Practical Introduction.*
#   Princeton University Press. https://socviz.co/
#
# Key principles applied here (see Healy ch. 1, 3, 8):
#   - Use theme_minimal() as a base; avoid heavy borders and backgrounds
#     (Healy 2018, ch. 8: "less non-data ink is almost always better")
#   - Prefer ColorBrewer palettes for categorical data; they are designed
#     to be perceptually uniform and colorblind-safe (ch. 1, 8)
#   - Use viridis for continuous scales -- perceptually ordered and
#     accessible across color-vision deficiencies (ch. 1)
#   - Remove minor gridlines; keep major gridlines light (ch. 8)
#   - Favor faceting (small multiples) over overloading a single plot
#     with too many colors or groups (ch. 4)
#   - Always label axes clearly and include a source caption (ch. 1)
#   - Use labs() for titles/subtitles/captions; let the data speak (ch. 3)
#   - Export at publication quality with explicit dimensions (ch. 8)
#
# Source once at the top of any analysis script:
#   source(here::here("source/lib/theme_healy.R"))
#
# What this does:
#   1. Defines theme_healy() built on theme_minimal()
#   2. Sets it as the session default via theme_set()
#   3. Provides palette helpers (scale_color_healy / scale_fill_healy)
#   4. Provides healy_save() -- a ggsave wrapper with sensible defaults
# ===========================================================================

library(ggplot2)
library(scales)

# ---------------------------------------------------------------------------
# 1. Custom theme
# ---------------------------------------------------------------------------
theme_healy <- function(base_size = 12, base_family = "") {
  theme_minimal(base_size = base_size, base_family = base_family) %+replace%
    theme(
      # Clean plot area
      panel.grid.minor   = element_blank(),
      panel.grid.major   = element_line(color = "grey90", linewidth = 0.3),

      # Axes
      axis.title         = element_text(size = rel(0.9), face = "plain"),
      axis.text          = element_text(size = rel(0.8), color = "grey30"),
      axis.ticks         = element_line(color = "grey70", linewidth = 0.3),

      # Legend: top by default, no box
      legend.position    = "top",
      legend.title       = element_text(size = rel(0.85)),
      legend.text        = element_text(size = rel(0.8)),
      legend.key         = element_blank(),

      # Titles
      plot.title         = element_text(size = rel(1.15), face = "bold",
                                        hjust = 0, margin = margin(b = 6)),
      plot.subtitle      = element_text(size = rel(0.9), color = "grey40",
                                        hjust = 0, margin = margin(b = 10)),
      plot.caption       = element_text(size = rel(0.7), color = "grey50",
                                        hjust = 1, margin = margin(t = 8)),
      plot.title.position = "plot",

      # Strip (facet) labels
      strip.text         = element_text(size = rel(0.85), face = "bold"),
      strip.background   = element_blank()
    )
}

# Set as session default
theme_set(theme_healy())

# ---------------------------------------------------------------------------
# 2. Color palettes  (ColorBrewer / viridis -- colorblind-safe)
# ---------------------------------------------------------------------------

# Discrete: qualitative ColorBrewer "Set2" (up to 8 categories)
scale_color_healy <- function(...) {
  scale_color_brewer(palette = "Set2", ...)
}
scale_fill_healy <- function(...) {
  scale_fill_brewer(palette = "Set2", ...)
}

# Continuous: viridis (perceptually uniform, colorblind-safe)
scale_color_healy_c <- function(...) {
  scale_color_viridis_c(option = "viridis", ...)
}
scale_fill_healy_c <- function(...) {
  scale_fill_viridis_c(option = "viridis", ...)
}

# ---------------------------------------------------------------------------
# 3. ggsave wrapper with publication defaults
# ---------------------------------------------------------------------------
healy_save <- function(filename, plot = last_plot(),
                       width = 6, height = 4, dpi = 300, ...) {
  ggsave(filename, plot = plot, width = width, height = height,
         dpi = dpi, bg = "white", ...)
}

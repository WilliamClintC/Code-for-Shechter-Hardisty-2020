# Code for Shechter & Hardisty (2020): Preferences for Rank in Competition

A complete, end-to-end replication of Shechter & Hardisty (2020), *Preferences for rank in competition: Is first-place seeking stronger than last-place aversion?*

Replication package prepared by **William Clinton Co**. The study itself is by Shechter & Hardisty (2020); this repository contains only the replication code and de-identified data (see [Citation](#citation)).

------------------------------------------------------------------------

## Overview

This is an academic replication package. It re-runs the original analysis from raw data through to the published tables and figures: it ingests the authors' raw competition data, reproduces the three studies' cleaned analysis samples (1960 / 1001 / 423 participants), and generates the paper's tables and figures.

------------------------------------------------------------------------

## What this package does and how to run it

The project uses a standard `source/` / `data/` / `output/` layout that mirrors three pipeline stages: `0_raw`, `1_derived`, and `2_analysis`. Every script runs from the project root, and each script finds the root itself by walking up to `run_all.py`.

### Stage 0: Ingest

`source/0_raw/ingest_competition_csvs/ingest_competition_csvs.ipynb` reads the six raw competition CSVs (`exp{58,72,73}_{wide,long}.csv`) and stacks the three studies into union-schema tables `wide_all.csv` and `long_all.csv`, adding `study` and `n_ranks` columns. No filtering happens here; because schemas differ across studies, columns missing from a given study become blank (NaN).

### Stage 1: Clean and derive

`source/1_derived/clean_competition/clean_competition.ipynb` produces the analysis-ready data through four ordered steps that land on 1960 / 1001 / 423:

1.  **Collection-window filter.** Keep only rows whose `dateadded` falls inside each study's real data-collection window. Rows before the window are test entries; rows after it are post-collection stimulus checks with placeholder demographics (such as `age = 1`). The filter uses collection date alone, never demographics.
2.  **IP deduplication (Studies 1 and 2 only; Study 3 is a lab sample and is exempt).** Per-IP rules keep the chronologically first respondent(s) per IP address, capped per study.
3.  **Complete-case drop.** Remove any row with a blank in a shown response cell.
4.  **Order.** Deduplication is applied before the complete-case drop.

It then converts each `rank{N}indif` indifference probability into a utility U(N) (anchors: U(1st) = 1, U(last) = 0) and computes the four per-participant boolean hypothesis indicators (H1, H2a, H2b, H4). Outputs: `wide_clean.csv` (one row per participant; 3384 rows × 55 columns) and `long_utils.csv` (one row per participant-rank; 20727 rows × 5 columns).

### Stage 2: Tables and figures

Seven scripts generate the published exhibits:

-   `table1_descriptives.ipynb` → Table 1 (per-study N, % male, mean age, competitiveness by gender).
-   `som1_joint_distribution.ipynb` → Table SOM.1 (the 16-cell joint distribution of the four indicators; roughly a quarter of each sample satisfies all four at once, far above the 6.25% chance rate).
-   `table2_3_proportions_magnitudes.R` → Table 2 / SOM.2 (% of participants TRUE on H1 / H2a / H2b / H4, with Wilson 95% confidence intervals) and Table 3 / SOM.3 (mean within-subject utility differences U(2) − U(last−1) and the drop-difference).
-   `figure1_utility_by_rank.R` → Figure 1 (mean utility by rank, Studies 1 and 2, with per-participant "spaghetti" lines and a 95% confidence interval).
-   `figure_som1_study3_bar.R` → Figure SOM.1 (Study 3 utility-by-rank bar chart).
-   `figure2_cpt_reanalysis.R` → Figure 2 (EUT versus CPT utility curves for Study 1).
-   `som_boxplots.R` → Figures SOM.2 / SOM.3 / SOM.4 (per-study utility boxplots).

Shared helpers live in `source/lib/`: `setup_libs.R` and `theme_healy.R` (a colorblind-safe ggplot2 theme following Healy's *Data Visualization*).

### Running the pipeline

From the project root:

``` bash
python run_all.py            # run the whole pipeline
python run_all.py --stage 0  # ingest only
python run_all.py --stage 1  # clean only
python run_all.py --stage 2  # tables and figures only
python run_all.py --dry-run  # print commands without executing
```

`run_all.py` dispatches by file extension (`.R` → `Rscript --vanilla`; `.ipynb` → `jupyter nbconvert --to notebook --execute --inplace`), fails fast on the first error, and writes a date-stamped master log to `output/run_all_<YYYYMMDD_HHMMSS>.log`.

### Requirements

-   **Python 3.11+** with `numpy`, `pandas`, and `tabulate`. Install with `pip install -r requirements.txt`.
-   **R 4.x** with `dplyr`, `readr`, `tidyr`, `ggplot2`, `scales`, `RColorBrewer`, `Hmisc`, and `knitr`. Install with `source("install.R")` (a local library lives in `.Rlib/`).

------------------------------------------------------------------------

## Repository structure

```         
Rank_Pref_Replication/
├── source/             All pipeline code (.R, .ipynb)
│   ├── 0_raw/          Ingest raw competition CSVs
│   ├── 1_derived/      Clean, deduplicate, derive utilities and indicators
│   ├── 2_analysis/     Tables (1, 2/SOM.2, 3/SOM.3, SOM.1) and figures (1, 2, SOM.1-4)
│   └── lib/            Shared helpers (setup_libs.R, theme_healy.R)
├── data/
│   ├── 0_raw/competition/        Raw exports (read-only): exp{58,72,73}_{wide,long}.csv, *_all.csv
│   └── 1_derived/competition/    Cleaned: wide_clean.csv, long_utils.csv
├── output/             Generated tables, figures, and run logs
│   ├── 1_derived/
│   ├── 2_analysis/{tables,figures}/
│   └── 3_verify/
├── docs/
│   └── codebook.md     Variable documentation for the cleaned data
├── run_all.py          Master pipeline script (stage dispatch by file extension)
├── install.R           R package installer
└── requirements.txt    Python packages
```

Raw data in `data/0_raw/` is read-only and should never be hand-edited. Everything in `data/1_derived/` and `output/` is generated by code.

------------------------------------------------------------------------

## Discrepancies, results, and fixes

While reconciling the cleaned samples and Table 2 against the published paper, the replication surfaced three points where the original cleaning recipe was ambiguous or internally inconsistent. Each was stress-tested by replacing the ambiguous rule with a single consistent rule, one at a time and then all together.

**Bottom line up front:** these choices move the exact sample sizes by only a handful of participants. Under every variant, each hypothesis stays supported at essentially the same proportion.

### D1: Per-study IP-deduplication cap (1 versus 2)

To remove duplicate respondents, the pipeline deduplicates by IP address. Study 1 keeps only **1** respondent per IP, but Study 2 keeps **2** (allowing for two people who share one household IP). This 1-versus-2 split is undocumented; the authors' written rule only says "keep the first respondent per IP," which implies a cap of 1 everywhere.

-   **What we did and found:** Applying one uniform cap to both studies fails to reproduce both published Ns at once. A cap of 1 for both costs Study 2 eleven participants (990 instead of 1001); a cap of 2 for both adds 32 to Study 1 (1992 instead of 1960). Only the asymmetric 1 / 2 split hits 1960 and 1001 simultaneously. Either way, every proportion moves at most 0.3 percentage points and no result changes.

### D2: Whole-IP drop for one inconsistent cluster

Exactly **one** IP in the entire dataset (Study 1, participant IDs 31715 / 32605) is dropped entirely rather than keeping its first attempt. The same person did the identical task twice (same experimental cell), and the first attempt was suspiciously fast (`numsecs = 56`). The pipeline encodes this as a "same person, same cell, drop the whole IP" rule, but with only one example it is indistinguishable from a simple "too fast / abandoned-then-redone" data-quality drop, and a global speed threshold cannot exist (the authors kept responses as fast as 47 seconds).

-   **What we did and found:** Removing this special branch and treating the cluster like every other (keep the chronologically first attempt, capped) moves Study 1 from 1960 to **1961** (a change of +1, since it retains the 56-second attempt). No other study is affected, and no proportion or magnitude changes. The special case exists only to land on exactly 1960.

### D3: Study 2 H1, strict versus relaxed definition

This is a discrepancy in the paper, not in the pipeline. The pipeline applies the strict monotone H1 definition (full non-increasing utility plus a strict top-to-bottom drop) uniformly to all three studies, giving H1 = 71.9% / 69.1% / 58.2%. The paper reports 72% / 86% / 58%. The strict rule matches Studies 1 and 3 exactly, but gives 69.1% for Study 2 versus the paper's 86%.

-   **What we did and found:** No single uniform definition reproduces all three published H1 values. The strict definition matches Studies 1 and 3 and misses Study 2; the relaxed definition (only U(2) \> U(last−1)) matches Study 2 (85.7%) but badly overshoots Study 1 (by about +15 pp) and Study 3 (by about +33 pp). The published 72 / 86 / 58 triple is only reconcilable if the authors used the strict definition for Studies 1 and 3 but the relaxed one for Study 2 alone, an internal inconsistency in the published table. Crucially, H1 stays strongly supported under either definition (far above the roughly 6% chance rate), so the substantive claim is unaffected.

### All three fixes together

Each discrepancy is binary, so the three together give 2 x 2 x 2 = 8 combinations (the two IP caps x the two whole-IP rules x the two H1 definitions). We ran every one of them. In all eight, the cleaned samples shift by at most a handful of participants, and **all five hypotheses (H1, H2a, H2b, H3, H4) stay supported** at essentially the same proportions (H3, that more participants are first-place seeking than last-place averse, was checked across the same eight combinations and holds throughout). The table lists the eight combinations with each study's sample size (change from the published 1960 / 1001 / 423 in parentheses); the last column confirms all five hypotheses hold:

| Cap | Whole-IP | H1 definition | Study 1 | Study 2 | Study 3 | All five hypothesis hold? |
|:---------:|:---------:|:---------:|----------:|----------:|----------:|:---------:|
| 1 | drop | strict | 1960 | 990 (-11, -1.1%) | 423 | ✓ |
| 1 | drop | relaxed | 1960 | 990 (-11, -1.1%) | 423 | ✓ |
| 1 | keep | strict | 1961 (+1, +0.1%) | 990 (-11, -1.1%) | 423 | ✓ |
| 1 | keep | relaxed | 1961 (+1, +0.1%) | 990 (-11, -1.1%) | 423 | ✓ |
| 2 | drop | strict | 1992 (+32, +1.6%) | 1001 | 423 | ✓ |
| 2 | drop | relaxed | 1992 (+32, +1.6%) | 1001 | 423 | ✓ |
| 2 | keep | strict | 1994 (+34, +1.7%) | 1001 | 423 | ✓ |
| 2 | keep | relaxed | 1994 (+34, +1.7%) | 1001 | 423 | ✓ |

The result, first-place seeking stronger than last-place aversion, holds in every combination. What the discrepancies move is the exact sample size, not the findings.

------------------------------------------------------------------------

## Data and provenance

The participant data in this package originates from the **original authors'** experiments (database exports for experiments exp58, exp72, and exp73).

### Privacy and de-identification

The raw exports included an `ip` column that the original cleaning used only to de-duplicate repeat respondents (Studies 1 and 2; Study 3, a lab sample, is exempt). No analysis, table, or figure uses the IP value itself. To protect participant privacy, every real IP address in this repository has been replaced with an opaque, consistent identifier through a one-to-one (bijective) mapping: the same original address always maps to the same id , and different addresses map to different ids. Because the mapping is one-to-one, the de-duplication grouping is preserved exactly, so the cleaning pipeline still reproduces the published samples (1960 / 1001 / 423) and every hypothesis proportion identically, while no real IP address is ever published. This was verified by re-running the full pipeline on the de-identified data.

## Citation {#citation}

> Shechter, Steven M., and David J. Hardisty (2020). "Preferences for rank in competition: Is first-place seeking stronger than last-place aversion?" *Judgment and Decision Making* 15(2):246-253. DOI: [10.1017/S1930297500007385](https://doi.org/10.1017/S1930297500007385).

To cite this package itself, see `CITATION.cff`.
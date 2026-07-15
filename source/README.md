# source/

All code, organized by pipeline stage. Supported languages: R (`.R`), Python
(`.py`), and Jupyter notebooks (`.ipynb`). Each task gets its own subfolder named
verb + noun in snake_case (for example `ingest_competition_csvs`,
`clean_competition`, `table1_descriptives`).

| Stage | What it does | Data flows to | Languages |
|-------|--------------|---------------|-----------|
| `0_raw/` | Ingest raw files and assemble them | `data/0_raw/` | `.ipynb` |
| `1_derived/` | Clean, reshape, transform | `data/1_derived/` | `.ipynb` |
| `2_analysis/` | Tables and figures | `output/2_analysis/` | `.R`, `.ipynb` |
| `lib/` | Shared helpers (`setup_libs.R`, `theme_healy.R`) | (none) | `.R` |

## Working directory

Every script runs with the project root as the working directory, which
`run_all.py` enforces. Each script also finds the root on its own by walking up
to `run_all.py`. Use paths relative to the project root; never use absolute
paths.

## Running

Run the whole pipeline with `python run_all.py`, or a single stage with
`python run_all.py --stage <0|1|2>`. See the top-level `README.md` for details.

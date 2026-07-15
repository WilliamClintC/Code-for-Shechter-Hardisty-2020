# Codebook

Variable documentation for the cleaned data produced by this pipeline. The
cleaning steps that create these files are in
`source/1_derived/clean_competition/clean_competition.ipynb`.

## Studies

The data cover three studies of preferences for rank in competition.

| Study | Code | Field | Contest size | Final N |
|:------|:-----|:------|:-------------|--------:|
| Study 1 | exp72 | MTurk, 2017-08-09 | 6 people | 1960 |
| Study 2 | exp73 | MTurk, 2018-02-01 | 6 people | 1001 |
| Study 3 | exp58 | Lab, 2015 (two waves) | 10 people | 423 |

Each participant reported, through a bisection procedure, the certainty
equivalent for several intermediate ranks, plus emotion ratings, a few
self-report attitudes, and demographics. The six-person studies elicit ranks 2,
3, 4, 5; the ten-person study elicits ranks 2, 3, 5, 8, 9.

## Files

- `data/1_derived/competition/wide_clean.csv`: one row per participant (3384
  rows, 55 columns). The analysis-ready table.
- `data/1_derived/competition/long_utils.csv`: one row per participant and rank
  (20727 rows, 5 columns). A reshaped view of the utilities, convenient for
  plotting.

---

## wide_clean.csv

### Identifiers and study

| Column | Type | Description |
|:-------|:-----|:------------|
| `study` | text | Study code: `exp72` (Study 1), `exp73` (Study 2), `exp58` (Study 3). |
| `n_ranks` | integer | Contest size: 6 for Studies 1 and 2, 10 for Study 3. |
| `row_id` | integer | Original database row identifier. |
| `pid` | integer | Participant identifier, unique within a study. |
| `code` | text | Completion code shown to the participant (`pid`-randomdigits). |

### Design factors (between-participant manipulations)

| Column | Type | Values | Description |
|:-------|:-----|:-------|:------------|
| `rlabel` | text | `w`, `n` | Rank wording shown to the participant: `w` = word labels ("first place", "second place", ...); `n` = numbers ("rank #1", "rank #2", ...). |
| `wording` | text | `word`, `numerical` | Readable form of `rlabel`. |
| `ordercon` | integer | 1, 2 | Order condition controlling the sequence in which ranks were queried. |
| `order` | text | `ascending`, `descending` | Readable form of `ordercon`. |
| `domain` | text | `i`, `p` | Framing of the contest: `i` = intelligence, `p` = physical. Present in the raw export for Studies 1 and 2; for Study 3 it is assigned from the collection wave (physical wave to `p`, intellectual wave to `i`). |
| `frame` | text | `intelligence`, `physical` | Readable form of `domain`. |
| `rankOrder` | text | e.g. `2,3,4,5` | The exact sequence of ranks queried for that participant. |

### Timing and provenance

| Column | Type | Description |
|:-------|:-----|:------------|
| `ip` | text | Respondent IP address (used for deduplication in Studies 1 and 2). |
| `dateadded` | datetime | When the response was started. Defines the collection-window filter. |
| `datemodified` | datetime | When the response was last updated. |
| `numsecs` | number | Completion time in seconds. |
| `nummins` | number | Completion time in minutes. |

### Elicited indifference probabilities

Each `rank{N}indif` is the probability *p* at which the participant is
indifferent between finishing in rank *N* for certain and a gamble that pays
first place with probability *p* and last place with probability (1 - *p*). It is
found by bisection (starting probability 0.5, convergence threshold 0.02). With
first place anchored at utility 1 and last place at 0, this probability is the
utility of rank *N*.

| Column | Type | Studies | Description |
|:-------|:-----|:--------|:------------|
| `rank2indif` | number | all | Indifference probability for rank 2. |
| `rank3indif` | number | all | Indifference probability for rank 3. |
| `rank4indif` | number | 1, 2 | Indifference probability for rank 4. |
| `rank5indif` | number | all | Indifference probability for rank 5. |
| `rank6indif`, `rank7indif` | number | (empty) | Present in the schema, not elicited. |
| `rank8indif` | number | 3 | Indifference probability for rank 8. |
| `rank9indif` | number | 3 | Indifference probability for rank 9. |

### Utilities (derived)

Utility of each rank, on a scale where first place is 1 and last place is 0.
Anchors are filled in directly; elicited ranks copy the matching `rank{N}indif`;
non-elicited ranks are blank.

| Column | Type | Description |
|:-------|:-----|:------------|
| `u1` | number | Utility of rank 1. Always 1. |
| `u2`–`u5` | number | Utility of ranks 2 to 5 (elicited). |
| `u6` | number | Utility of rank 6. For six-person studies this is the last place, always 0. |
| `u7` | number | Utility of rank 7 (empty; not elicited). |
| `u8`, `u9` | number | Utility of ranks 8 and 9 (Study 3, elicited). |
| `u10` | number | Utility of rank 10. For the ten-person study this is the last place, always 0. |

### Emotion and attitude items

All are 7-point scales.

| Column | Type | Studies | Description |
|:-------|:-----|:--------|:------------|
| `actuallyrank` | integer | all | "How do you think you would actually rank in such a contest?" The rank the participant expects to finish in. |
| `feel1`, `feel2`, `feel5`, `feel6` | integer | 1, 2 | "If you were to finish in rank N, how would you feel?" 1 = really bad, 7 = really great. One rank, drawn at random from {1, 2, 5, 6}, is asked per participant, so only one of these columns is filled per row. |
| `feelfirst`, `feellast` | integer | 3 | The ten-person analogue: emotion if finishing first or last. One is asked per participant. |
| `feeldrop` | integer | all | "Which would feel worse, dropping from rank 1 to 2, or from rank 5 to 6?" 1 = dropping from 1 to 2 feels much worse, 4 = equally bad, 7 = dropping from 5 to 6 feels much worse. |
| `feelrise` | integer | all | "Which would feel better, rising from rank 2 to 1, or from rank 6 to 5?" 1 = rising 2 to 1 feels much better, 4 = equally good, 7 = rising 6 to 5 feels much better. |
| `howcompetitive` | integer | all | "In general, how competitive are you as a person?" 1 = not at all, 7 = very. |
| `howfitm` | integer | 1, 2 | "How would you rate your mental fitness?" 1 = not at all fit, 7 = very fit. |
| `howfitp` | integer | 1, 2 | "How would you rate your physical fitness?" 1 = not at all fit, 7 = very fit. |
| `howfit` | integer | 3 | Single fitness rating for the lab study (the domain is fixed within a wave). |

### Demographics

| Column | Type | Values | Description |
|:-------|:-----|:-------|:------------|
| `gender` | text | `F`, `M` | Self-reported gender (Female, Male, as presented). A few rows in the raw export also carry `O` or `N`. |
| `age` | number | years | Self-reported age in years. |
| `ethnicity` | text | see below | Self-reported ethnicity: American Indian or Alaskan Native, Asian, Black or African American, White, Hispanic or Latin American, Other. |

### Hypothesis indicators (derived)

Each is a per-participant boolean. U(N) denotes the utility of rank N.

| Column | Type | Definition |
|:-------|:-----|:-----------|
| `H1` | boolean | Non-increasing utility across elicited ranks, with a strict drop from rank 2 to the second-to-last rank. Six-person: U(2) ≥ U(3) ≥ U(4) ≥ U(5) and U(2) > U(5). Ten-person: U(2) ≥ U(3) ≥ U(5) ≥ U(8) ≥ U(9) and U(2) > U(9). |
| `H2a` | boolean | Convexity near the top: U(2) - U(3) < U(1) - U(2). |
| `H2b` | boolean | Concavity near the bottom. Six-person: U(5) - U(6) > U(4) - U(5). Ten-person: U(9) - U(10) > U(8) - U(9). |
| `H4` | boolean | The drop from first place exceeds the drop into last place. Six-person: U(1) - U(2) > U(5) - U(6). Ten-person: U(1) - U(2) > U(9) - U(10). Compared at two-decimal precision. |

---

## long_utils.csv

One row per participant and rank, holding the anchor ranks (first and last) and
the elicited ranks only.

| Column | Type | Description |
|:-------|:-----|:------------|
| `study` | text | Study code (`exp72`, `exp73`, `exp58`). |
| `pid` | integer | Participant identifier. |
| `n_ranks` | integer | Contest size (6 or 10). |
| `rank` | integer | Rank number. |
| `utility` | number | Utility of that rank for that participant (first place 1, last place 0). |

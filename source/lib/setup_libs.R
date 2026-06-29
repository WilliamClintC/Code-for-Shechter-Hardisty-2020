# Prepend the project-local .Rlib (if present) to the search path.
# Lets us shim newer package versions without disturbing the user's main lib.
.project_root <- (function() {
  d <- getwd()
  while (!file.exists(file.path(d, "run_all.py"))) {
    pd <- dirname(d)
    if (pd == d) return(getwd())
    d <- pd
  }
  d
})()
.local_lib <- file.path(.project_root, ".Rlib")
if (dir.exists(.local_lib)) {
  .libPaths(c(.local_lib, .libPaths()))
}

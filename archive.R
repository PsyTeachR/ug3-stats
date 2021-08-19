suppressMessages(if (!requireNamespace("RCurl")) {
  stop("package 'RCurl' was not found; please install")
})

suppressMessages(if (!requireNamespace("yaml")) {
  stop("package 'yaml' was not found; please install")
})

.outvars <- yaml::yaml.load_file("_output.yml")
.bdwnvars <- yaml::yaml.load_file("_bookdown.yml")

prompt <- if (!interactive()) {
            length(commandArgs(TRUE)) == 0L
          } else {
            TRUE
          }

desturl <- if (interactive()) {
             ## prompt user for the URL of the current edition
             message("The archived version should contain a link (URL, e.g. https://...) to a more recent version.")
             message("Readers will be forwarded to this URL.")
             res <- readline("Enter forwarding URL (or 'q' to quit): ")
             if ((res == "q") || (res == "Q")) {
               stop("script aborted")
             }
           } else {
             if (length(commandArgs(TRUE)) > 0L) {
               commandArgs(TRUE)[1]
             } else {
               stop("need to supply destination URL as command-line argument")
             }
           }

if (!RCurl::url.exists(desturl)) {
  stop("URL '", desturl, "' is not a valid URL (e.g., https://...)")
}

if (file.copy("_bookdown.yml", "_bookdown.yml.backup", overwrite=FALSE)) {
  message("Backed up _bookdown.yml to _bookdown.yml.backup")
}
if (file.copy("_output.yml", "_output.yml.backup", overwrite = FALSE)) {
  message("Backed up _output.yml to _output.yml.backup")
}

## update CSS to provide archive link

.outvars[["forwarding_url"]] <- desturl
.outvars[["bookdown::gitbook"]][["config"]][["toc"]][["before"]] <-
  paste0("<h2 style=\"color:red;\">WARNING: You are reading an old version of this textbook.</h2><p><a href=\"", desturl, "\">Go to the latest version</a></p>")

cat(".book .book-summary {",
    "    background-color: rgb(255, 255, 200);",
    "}",
    sep = "\n",
    file = "include/archive.css",
    append = FALSE)

## add include/archive.css in 
if (!("include/archive.css" %in% .outvars[["bookdown::gitbook"]][["css"]])) {
  .outvars[["bookdown::gitbook"]][["css"]] <-
    c(.outvars[["bookdown::gitbook"]][["css"]], "include/archive.css")
}

yaml::write_yaml(.outvars, file = "_output.yml")

cat("Book styles have been updated. Now you need to recompile the book.\n")
cat("Before doing that, ")
cat("it is a good idea to manually add the following lines",
    "to each of your RMarkdown files, somewhere after the first level-1 heading:",
    "\n",
    sep = "\n")
cat("::: {.warning}",
    "<h2>You are reading an old version of this textbook.</h2>",
    paste0("<a href=\"", desturl, "\">Go to the latest version</a>"),
    ":::\n", sep = "\n")

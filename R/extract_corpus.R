#' Extract text from one to many pdf documents into a tm Corpus.
#'
#' @importFrom tm Corpus URISource readPDF
#' @importFrom plyr rbind.fill
#'
#' @export
#'
#' @param paths Path to a file
#' @param which One of gs, or xpdf.
#' @param ... further args passed on
#' @return A tm Corpus or VCorpus
#' @examples \donttest{
#' paths <- c("~/github/sac/scott/pdfs/BarraquandEtal2014peerj.pdf",
#' "~/github/sac/scott/pdfs/Chamberlain&Holland2009Ecology.pdf",
#' "~/github/sac/scott/pdfs/Revell&Chamberlain2014MEE.pdf")
#' res <- extract_corpus(paths, "gs")
#' res
#' tm::TermDocumentMatrix(res$data)
#'
#' res <- extract_corpus(path, "xpdf")
#' res
#' }
extract_corpus <- function(paths, which, ...){
  switch(which,
         gs = extract_tm_gs(paths, ...),
         xpdf = extract_tm_xpdf(paths, ...)
  )
}

extract_tm_gs <- function(paths, which, ...){
  paths <- process_paths(paths)
  out <- Corpus(URISource(paths), readerControl =
            list(reader = readPDF(engine = "ghostscript", control = list(...))))
  meta <- get_meta(out)
  structure(list(meta = meta, data = out), class = "xpdf")
}

extract_tm_xpdf <- function(paths, which, ...){
  paths <- process_paths(paths)
  out <- Corpus(URISource(paths), readerControl =
                   list(reader = readPDF(engine = "xpdf", control = list(...))))
  meta <- get_meta(out)
  structure(list(meta = meta, data = out), class = "xpdf")
}

files_exist <- function(x){
  tmp <- sapply(x, file.exists)
  if (!all(tmp)) stop(sprintf("These do not exist or can not be found:\n%s",
                             paste(names(tmp[tmp == FALSE]), collapse = "\n") ))
}

get_meta <- function(input){
  do.call(rbind.fill, lapply(input, function(x) {
    tmp <- attributes(x)
    tmp[sapply(tmp, length) == 0] <- NA
    tmp <- lapply(tmp, function(z) if (length(z) > 1) {
                                      paste(z, collapse = ", ")
                                    } else z)
    data.frame(tmp, stringsAsFactors = FALSE)
  }))
}

process_paths <- function(x){
  files_exist(x)
  path.expand(x)
}

#
# print.gs_char <- function(x, ...) {
#   cat("<document>", attr(x, "path"), "\n", sep = "")
#   cat("  Title: ", x$meta$Title, "\n", sep = "")
#   cat("  Producer: ", x$meta$Producer, "\n", sep = "")
#   cat("  Creation date: ", as.character(as.Date(x$meta$CreationDate)), "\n", sep = "")
# }
#
#
# print.xpdf_char <- function(x, ...) {
#   cat("<document>", attr(x, "path"), "\n", sep = "")
#   cat("  Pages: ", x$meta$Pages, "\n", sep = "")
#   cat("  Title: ", x$meta$Title, "\n", sep = "")
#   cat("  Producer: ", x$meta$Producer, "\n", sep = "")
#   cat("  Creation date: ", as.character(as.Date(x$meta$CreationDate)), "\n", sep = "")
# }

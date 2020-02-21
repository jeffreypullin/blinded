#' Rate images blindly
#'
#' The `rate_blindly()` function is desinged to faciliate the task of
#' rating a set of images blindly - that is without knowledge of any
#' characteristics of the image.
#'
#' This task is complicated by the fact that images are generally stored with
#' filenames that contain information about the image. This may also mean
#' that the ordering of images in a file system is affected by
#' chracteristics of the images.
#'
#' To circumvent these issues `rate_blindly()` provides an interface where
#' images are shown to the rater *without filenames* and in a *random* order.
#'
#' If you enter "save" as a rating then the rating
#'
#' @details Currently `rate_blindly()` depends on magick's integration with
#'   the RStudiov viewer pane to display images. The function will therefore
#'   fail (informatively) in non-RStudio R editing enviroments.
#'
#'   If you enter "save" as a rating the rating 'session' (the list of ratings
#'   made to date) will be saved and the rating session can be resumed at a
#'   later date.
#'
#' @param dir The directory the images are in. This directory must not contain
#'   any other files. An image is defined as anything [magick::image_read()]
#'   can read.
#'
#' @return A tibble with two columns.
#'   file_name: The file name of the image
#'   rating: The rating given to the image
#'
#' @importFrom magick image_read
#' @importFrom tibble tibble
#' @importFrom rstudioapi isAvailable
#' @importFrom yesno yesno2
#'
#' @export
#'
rate_blindly <- function(dir) {

  if (!rstudioapi::isAvailable()) {
    stop("`rate_blindly()` requires the RStudio veiwing pane to display images",
         call. = FALSE)
  }

  all_paths <- list.files(dir, full.names = TRUE, all.files = TRUE, no.. = TRUE)

  has_saved_session <- any(basename(all_paths) == saved_session_file_name)
  if (has_saved_session) {
    cat("Saved rating session detected.\n")
    resume <- yesno::yesno2("Would you like to resume the saved session?\n",
                           "(If you do not the session will be deleted)\n")
    if (resume) {
      # Resume the session.
      session <- readRDS(file.path(dir, saved_session_file_name))
      out <- rate_files_blindly(session$paths, session$ratings)
    } else {
      # Remove the saved session and start a new one.
      file.remove(dir, saved_session_file_name)
      out <- rate_files_blindly(sample(all_paths), list())
    }

  } else {
    # Start a new session.
    out <- rate_files_blindly(sample(all_paths), list())
  }

  # Cleanup.
  # We are returning a tibble (i.e. not saving) and have used a saved session.
  if (!is.null(out) && has_saved_session) {
    cat("All items rated. Deleting saved rating session...")
    file.remove(file.path(dir, saved_session_file_name))
  }

  out
}

rate_files_blindly <- function(paths, ratings) {
  stopifnot(!any(basename(paths) == saved_session_file_name))

  N <- length(paths)
  n <- length(ratings)
  stopifnot(n < N)
  for (i in (n + 1):N) {
    cat("Displaying image", i, "of", N, "\n")

    image <- magick::image_read(paths[[i]])
    # Magick produces extra output which we capture.
    capture.output(image, file = "/dev/null")

    ratings[[i]] <- readline(prompt = "Please enter your rating: ")

    if (tolower(ratings[[i]]) == "save") {
      return(save_rating_session(paths, ratings[-i]))
    }
  }

  # Assume that ratings are numerical.
  tibble::tibble(
    file_name = basename(paths),
    rating    = as.numeric(ratings)
  )
}

save_rating_session <- function(paths, ratings) {
  rating_session <- list(paths = paths,
                         ratings = ratings)

  dir <- dirname(paths[[1]])
  saveRDS(rating_session, file = file.path(dir, saved_session_file_name))

  cat("Rating session saved.\n")
  cat("Run `rate_blindly()` with the same directory to resume the session.")

  return(invisible(NULL))
}

saved_session_file_name <- ".blinded_saved_session"

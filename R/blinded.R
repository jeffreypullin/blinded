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
#' @details Currently `rate_blindly()` depends on magick's integration with
#' the RStudiov viewer pane to display images. The function will therefore
#' fail (informatively) in non-RStudio R editing enviroments.
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
#' @importFrom rstudioapi isAvaiable
#'
#' @export
#'
rate_blindly <- function(dir) {

  if (!rstudioapi::isAvailable()) {
    stop("Currently `rate_blindly()` requires the RStudio veiwing pane
         to display images", call. = FALSE)
  }

  paths <- list.files(dir, full.names = TRUE)
  N <- length(paths)

  # Randomise the order the files are shown the order
  paths <- sample(paths, N)

  ratings <- list()
  for (i in 1:N) {
    cat("Displaying image", i, "of", N, "\n")

    # Read and display the image
    image <- magick::image_read(paths[[i]])
    capture.output(image, file = "/dev/null")

    ratings[[i]] <- readline(prompt = "Please enter your rating: ")
  }

  # Assume that ratings are numerical
  tibble::tibble(
    file_name = basename(paths),
    rating    = as.numeric(ratings)
  )
}

#' Rate images blindly
#'
#' @param dir The directory the images are in.
#'
#' @details This function is designed to assist people who need to blindly rate
#'  a set of images (i.e. rate the images without knowing any characteristics
#'  of the subject of the image). To achieve this the images are shown to the
#'  rater randomly and without showing the file name (which may contain
#'  information about the image).
#'
#' @return A tibble with two columns.
#'   file_name: The file name of the image
#'   rating: The rating given to the image
#'
#' @importFrom magick image_read
#' @importFrom tibble tibble
#'
#' @export
#'
rate_blindly <- function(dir) {
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

rate_blindly("/Users/jeffreypullin/Desktop/screen_shots")

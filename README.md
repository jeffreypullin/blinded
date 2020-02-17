# Blinded :see_no_evil:

**blinded** is desinged to faciliate the task of
rating a set of images blindly - that is without knowledge of any
characteristics of the image.

This task is complicated by the fact that images are generally stored with
filenames that contain information about the image. This may also mean
that the ordering of images in a file system is affected by
chracteristics of the images.

To circumvent these issues **blinded** provides the function `rate_blindly()`.

Running `rate_blindly()` on a directory of images will open the images and 
allow ratings to be entered. The images will be opened **without showing filenames** 
and in a **random** order.

## Caveat

**blinded** currently depends on **magick**'s integration with RStudio's viewer 
pane to display images. This means that **blinded** will not work in other 
R editing environements.  

## Install

To install the package run:

```r
remotes::install_github("jeffreypullin/blinded")
```

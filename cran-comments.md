# Resubmission 1

CRAN team -
This is a first resubmission of a new package, responding to feedback from Martina Schmirl on intial submission below.

#> 1. You write information messages to the console that cannot be easily
#> suppressed. It is more R like to generate objects that can be used to
#> extract the information a user is interested in, and then print() that
#> object. Instead of print()/cat() rather use message()/warning() if you
#> really have to write text to the console.

Removed all mentions of cat()/print() in the package, other than in print method 
of the `polite` class. Simplified print method by removing dependency on `crayon`.

#> 2. When creating the examples please keep in mind that the structure
#> would be desirable:
#> \examples{
#>     examples for users and checks:
#>     executable in < 5 sec
#>     \dontshow{
#>         examples for checks:
#>         executable in < 5 sec together with the examples above
#>         not shown to users
#>     }
#>     \donttest{
#>         further examples for users; not used for checks
#>         (f.i. data loading examples )
#>     }
#>     \dontrun{
#>         not used by checks, not used by example()
#>         adds the comment ("# Not run:") as a warning for the user.
#>     }
#>     if(interactive()){
#>         functions not intended for use in scripts,
#>         or are supposed to only run interactively
#>         (f.i. shiny)
#>     }
#> }

Removed redundant  \dontrun statements in `scrape()` function and controlled that all 
documentation section use consistent formatting for examples.

#> 3. Please ensure that your functions do not write by default or in your
#> examples/vignettes/tests in the user's home filespace (including the
#> package directory and getwd()). That is not allow by CRAN policies.
#> Please only write/save files if the user has specified a directory in
#> the function themselves. In your examples/vignettes/tests you can write to tempdir().

Corrected `rip()` to write into `tempdir()` instead of local directory.

Thank you for reviewing my submission!
Regards,
Dmytro

# Initial submission notes

## Test environments
- R-hub windows-x86_64-devel (r-devel)
- R-hub ubuntu-gcc-release (r-release)
- R-hub fedora-clang-devel (r-devel)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

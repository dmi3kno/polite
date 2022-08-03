# polite (development version)

# polite 0.1.2 (Release date: 2022-08-03)

* Released on CRAN. Initial release v0.1.2

# polite 0.1.1.9020 (Release date: 2020-06-12)

* Added `politely` adverb
* Fixed bug related to incorrect calling of bow() inside the nod() function #31
* Added `times` argument to `bow()` to control default number of retries #36
* Fixed a bug on.exit() restoring the user-agent #29
* Switched to webmockr for testing infrastructure

# polite 0.1.1.9010 (Release date: 2020-03-29)

* Replaced httr::GET with httr::RETRY (closing #24)
* Removed tests base on Wikipedia due to changed routing
* Removed dependency on `here`

# polite 0.1.1 (Release date: 2019-11-22)

* Released on CRAN. Initial release v0.1.1

# polite 0.1.0 (Release date: 2019-07-07)

* submitted to CRAN

# polite 0.0.0.9007 (Release date: 2019-06-30)

* the `param` argument of `scrape()` is now softly deprecated. New argument `query` is introduced. (closing [#16](https://github.com/dmi3kno/polite/issues/16))
* dependency on `urltools` is removed in favor of native functions in `httr`
* new `usethis`-like function `use_manners()` for producing own polite scraping infrastructure is included

# polite 0.0.0.9006 (Release date: 2018-08-10)

* added `set_scrape_delay()` and `set_rip_delay()` to adjust default scraping rate limit
* took `httr_rate_ltd()` out of `bow()` (closing [#9](https://github.com/dmi3kno/polite/issues/9))

# polite 0.0.0.9005 (Release date: 2018-08-10)

* added `html_attrs_dfr()` - function for tidying html_attrs()
* added polite download function called `rip()`

# polite 0.0.0.9004 (Release date: 2018-07-30)

* rate-limited `GET` function is now a method instantiated inside `bow` to allow for setting persistent `delay` argument
* messages (but not warnings) from robotstxt are suppressed for cleaner console
* added `content` parameter to `scrape()` for overriding default data type and encoding

# polite 0.0.0.9003 (Release date: 2018-07-30)

* Argument for setting up crawl delay has been renamed from `period` to `delay` and moved from `scrape` to `bow`.
* Print method and warning messages reflect `delay` argument set for the session.

# polite 0.0.0.9002 (Release date: 2018-07-29)

* Added a `NEWS.md` file to track changes to the package.
* Added custom print method for `polite session` using `crayon`
* `bow` and `nod` now warn if the current path is not permitted to be scraped 
* `polite` has gotten a sticker! `png` is stored in `data-raw`


# polite v0.0.0.9001 (Release date: 2018-07-27)

* Implemented bow(), nod() and scrape()
* Added documentation and examples
* Updated README to include examples


# polite v0.0.0.9000 (Release date: 2018-07-23)

* Polite is born!

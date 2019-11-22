# polite 0.1.1 (Release date: 2019-11-22)

* Re-submitted to CRAN

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

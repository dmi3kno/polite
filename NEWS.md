# polite 0.0.0.9005 (Release date: 2018-08-10)

* added html_attrs_dfr() - function for tidying html_attrs()

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

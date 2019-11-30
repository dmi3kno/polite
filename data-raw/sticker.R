library(hexSticker)
imgurl <- "https://raw.githubusercontent.com/dmi3kno/DataCamp-IntroToExpDesign/master/d91ad16fb06abcc7e19447870fd743d1.png"
sticker(imgurl, package = "polite", p_size = 24, p_color="#4F6D7A",
        h_fill="#ffffff", h_color="#4F6D7A",
        s_x=1, s_y=.75, s_width = .6,
        filename = "sticker.png")

# updating ghcard after CRAN release
library(magick)
library(bunny)

bg_color <- "#ffffff"
fg_color <- "#4F6D7A"

polite_hex_gh <- image_read("data-raw/sticker.png") %>%
  image_scale("400x400")

polite_ghcard <- image_canvas_ghcard(fill_color = bg_color) %>%
  image_composite(polite_hex_gh, gravity = "East", offset = "+100+0") %>%
  image_annotate("Be nice on the web", gravity = "West", location = "+60-50",
                 color=fg_color, size=60, font="Aller", weight = 700) %>%
  #image_compose(gh_logo, gravity="West", offset = "+60+40") %>%
  image_annotate("# Now available on CRAN!", gravity="West", location="+60+20",
                 color="grey70", style = "italic", size=40, font="Ubuntu Mono") %>%
  image_annotate("install.packages('polite')", gravity="West", location="+60+65",
                 size=40, font="Ubuntu Mono") %>%
  image_border_ghcard(bg_color)

polite_ghcard

polite_ghcard %>%
  image_write("data-raw/polite_ghcard.png", density = 600)

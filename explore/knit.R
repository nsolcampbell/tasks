for (file in list.files(pattern="*.Rmd")) {
  require(knitr) # required for knitting from rmd to md
  require(markdown) # required for md to html 
  md = sub(".Rmd$", ".md", file)
  html = sub(".Rmd$", ".html", file)
  knit(file, md) # creates md file
  markdownToHTML(md, html) # creates html file
}

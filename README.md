Polarization
============

An analysis of workforce and skill polarization in Australia. 

This is a work in progress. Please do not cite.

Documents
---------

If you're just after the output documents, they're available as PDFs:

 * [In-progress working paper](https://github.com/adrcooper/tasks/blob/master/doc/thesis.pdf?raw=true)
 * [In-progress annotated bibliography](https://github.com/adrcooper/tasks/blob/master/doc/annotated_bibliography.pdf?raw=true)
 * [Announcement slides](https://github.com/adrcooper/tasks/blob/master/doc/presentation.pdf?raw=true)

Obtaining and Building
----------------------

If you're mad enough, the LaTeX documents and analyses can be rebuilt from scratch. You'll need a reasonable *NIX environment with R 3.0, build tools and a decent TeX distribution.

Simply execute:

    git clone https://github.com/adrcooper/tasks.git
    cd tasks
    make all

If all goes well, the final thesis.pdf file can be found in the doc/ directory.

Data sources
------------
Data files are in *data/* subdirectory.

* 5204.0 Australian national accounts
  * net capital stock in machinery and equipment
  * gross capital formation of machinery and equipment by industry
  * net capital stock, ICT
  * gross capital formation, ICT
  * consumption of fixed capital, ICT
* O*NET task database 
  * Ability, skill and knowledge tables, by level and importance (CSV)

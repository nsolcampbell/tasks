Polarization
============

An analysis of workforce and skill polarization in Australia. The analysis is reproducible, although you'll need access to the relevant census CURFs, available from the Bureau of Statistics.

Documents
---------

If you're just after the output documents, they're available as PDFs:

 * [In-progress thesis](https://github.com/kuperov/polarization/blob/master/doc/thesis.pdf?raw=true)
 * [In-progress annotated bibliography](https://github.com/kuperov/polarization/blob/master/doc/annotated_bibliography.pdf?raw=true)
 * [Announcement slides](https://github.com/kuperov/polarization/blob/master/doc/presentation.pdf?raw=true)

Obtaining and Building
----------------------

If you're mad enough, the LaTeX thesis documents and analyses can be rebuilt from scratch. You'll need a reasonable *NIX environment with R 3.0, build tools and a decent TeX distribution.

Simply execute:

    git clone https://github.com/kuperov/polarization.git
    cd polarization
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
  * Original MS Access file
  * Original O*NET data dumped out as CSVs

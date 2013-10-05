#!/usr/bin/env python

# Unzip the RADL output archive to create a results.../ subdirectory
# in the current directory, then execute:
#
#    usage: ./parse_rif_2010.py <OUTPUT_NUMBER>
#
# where <OUTPUT_NUMBER> is the RADL job serial number, e.g. 65

# Parse RIF regression results for all 19 quantiles

import re
import sys

result_id = int(sys.argv[1])
nquant    = 19
# note the variable list includes omitted variables, which
# will simply be left blank in the resulting matrix
variables = """
quantile
expdum1 expdum2 expdum3 expdum4 expdum5 expdum6 expdum7 expdum8 expdum9 
educ1 educ2 educ3 educ4 educ5
female
married
inform
routine
face
site
decision
_cons
""".split()
quant_hdr = re.compile("^. reg rif_(\d+)")
reg_res_re = "^ +(" + "|".join(variables) + ") \\| +([0-9.-]+) "
reg_res   = re.compile(reg_res_re)
results   = [[0 for col in range(len(variables))] for row in range(nquant)]
outfile   = "rif_2010.csv"

# first populate quantile list
for q in range(19):
    results[q][0] = 0.05 * (1+q)
# process text file output and jam parameter 
# point estimates into the grid
with open("results%04d/output%04d.txt" % (result_id, result_id), 'r') as f:
    for line in f:
        result = quant_hdr.match(line)
        if result:
            quantile = int(result.group(1))
            print "Quantile %(q)d" % {'q': quantile}
        result = reg_res.match(line)
        if result:
            variable = result.group(1)
            estimate = float(result.group(2))
            print "\t%(v)s = %(est)f" % {'v': variable, 'est': estimate}
            results[quantile-1][variables.index(variable)] = estimate

import csv
with open(outfile, "wb") as f:
    writer = csv.writer(f)
    writer.writerow(variables)
    writer.writerows(results)
print "Wrote results to %(outfile)s" % {'outfile': outfile}

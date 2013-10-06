#!/usr/bin/env python

# Unzip the RADL output archive to create a results.../ subdirectory
# in the current directory, then execute:
#
#    ./parse_rif_log.py <OUTPUT_NUMBER> <OUTFILE.csv>
#
# where <OUTPUT_NUMBER> is the RADL job serial number, e.g. 65
# and <OUTFILE.csv> is the base CSV file to write out, e.g. 2010_1

# Parse RIF regression results for all 19 quantiles

import re
import sys

result_id = int(sys.argv[1])
nquant    = 19

# note the variable list includes omitted variables, which
# will simply be left blank in the resulting matrix
variables = """
   quantile
   expdum1 expdum2 expdum3 expdum5 expdum6 expdum7 expdum8
   educ1 educ2 educ4 educ5
   female
   married
   inform
   routine
   face
   site
   decision
   _cons
   """.split()

# regular expressions for finding what we want

quant_hdr = re.compile("^. reg rif_(\d+)")
reg_res_re = "^ +(" + "|".join(variables) + ") \\| +([0-9.-]+) "
reg_res   = re.compile(reg_res_re)

begin_EX  = re.compile("BEGIN EXPECTED VALUE OF X")
end_EX    = re.compile("END EXPECTED VALUE OF X")
summ_res_re = "^ +(" + "|".join(variables) + ") \\| +(?:[0-9.e+-]+ +){3}([0-9.e+-]+)"
summ_res  = re.compile(summ_res_re)

begin_OD  = re.compile("BEGIN OVERALL DISTRIBUTION")
end_OD    = re.compile("END OVERALL DISTRIBUTION")
dist_res  = re.compile("^ +([0-9]+). \| +([0-9.-]+)")

mean_occ  = re.compile("^ *COMBINEDI+==([0-9]+) *\| +([0-9.-]+)")

# empty results matrix
results   = [[0 for col in range(len(variables))] for row in range(nquant)]
# expected value vector
EX_matrix = [0 for i in range(len(variables))]
# overall distribution quantile vector
OD_vector = [0 for i in range(19)]
# mean occupational wage vector (28/29 entries)
wage_vect = [0 for i in range(29)]

# filename slug
outfile   = sys.argv[2]

# first populate quantile list
for q in range(19):
    results[q][0] = 0.05 * (1+q)
# process text file output and jam parameter 
# point estimates into the grid
quantile = 1
with open("results%04d/output%04d.txt" % (result_id, result_id), 'r') as f:
    # parser state variables 
    EX = False # Saving E[X]
    OD = False # Saving quantiles
    
    for line in f:
        if begin_EX.search(line) != None:
            EX = True
        elif end_EX.search(line) != None:
            EX = False
        elif begin_OD.search(line) != None:
            OD = True
        elif end_OD.search(line) != None:
            OD = False
        elif EX:
            # we're in "saving E[X]" mode
            result = summ_res.match(line)
            if result:
                variable = result.group(1)
                estimate = float(result.group(2))
                if variables.index(variable) >= 0:
                    # note: exclude omitted groups
                    EX_matrix[variables.index(variable)] = estimate
        elif OD:
            result = dist_res.match(line)
            if result:
                quantile = int(result.group(1))
                estimate = float(result.group(2))
                OD_vector[quantile-1] = estimate
        else:
            # saving regressions/mean occupations mode
            result = mean_occ.match(line)
            if result:
                quantile = int(result.group(1))
                mean = float(result.group(2))
                wage_vect[quantile - 1] = mean
            result = quant_hdr.match(line)
            if result:
                quantile = int(result.group(1))
            result = reg_res.match(line)
            if result:
                variable = result.group(1)
                estimate = float(result.group(2))
                results[quantile-1][variables.index(variable)] = estimate

import csv

riffile = "../../data/rif/%s.csv" % outfile
exfile  = "../../data/EX/%s.csv" % outfile
odfile  = "../../data/quantiles/overall_%s.csv" % outfile
meanfile = "../../data/means/%s.csv" % outfile

with open(exfile, "wb") as f:
    writer = csv.writer(f)
    writer.writerow(variables)
    writer.writerow(EX_matrix)
print "Wrote E[X|T=t] to %s" % exfile

with open(meanfile, "wb") as f:
    writer = csv.writer(f)
    writer.writerow(wage_vect)
print "Wrote means to %s" % exfile

with open(odfile, "wb") as f:
    writer = csv.writer(f)
    writer.writerow(["id", "q", "est"])
    for i in range(19):
        writer.writerow([i+1, 0.05*(i+1), OD_vector[i]])
print "Wrote {q_1 .. q_19} to %s" % odfile

with open(riffile, "wb") as f:
    writer = csv.writer(f)
    writer.writerow(variables)
    writer.writerows(results)
print "Wrote RIF results to %s" % riffile

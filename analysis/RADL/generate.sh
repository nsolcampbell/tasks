#!/usr/bin/env bash

./make_reweighted_rif_2010.py 1 > reweighted_rif_2010_1.do
./make_reweighted_rif_2010.py 2 > reweighted_rif_2010_2.do
./make_rif_2010.py 1 > rif_2010_1.do
./make_rif_2010.py 2 > rif_2010_2.do
./make_rif_2001.py > rif_2001.do

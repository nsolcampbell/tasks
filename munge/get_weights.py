#!/usr/bin/env python

print ','.join(["IDENT_PSN","FAMNO_PSN", "IUNO_PSN","PERSON_NUMBER","PERS_WT"])
with open('../data/curf/ids_82/IDS82.DAT') as f:
    for line in f:
	    if line[8] == '2': # person record
		IDENT_PSN = line[0:8] # 1:8
		person_weight = line[392:400] # 393:400
		IUNO_PSN = line[10:12] # 11:12
		FAMNO_PSN = line[9] # 10
		PERSON_NUMBER = line[12:14] # 13:14
		print ','.join([IDENT_PSN, FAMNO_PSN, IUNO_PSN, PERSON_NUMBER, person_weight])

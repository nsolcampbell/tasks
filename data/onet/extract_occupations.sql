select * 
	INTO OUTFILE '/tmp/occup.csv'
	FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
	ESCAPED BY '\\'
	LINES TERMINATED BY '\n'
from onet.occupation_data;

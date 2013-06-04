select 'Knowledge' as Dimension,
	occupation.onetsoc_code,
	occupation.title,
	occupation.description,
	model.element_name, 
	model.description,
	know.data_value, scale.scale_name,
	know.n, know.lower_ci_bound, know.upper_ci_bound
#	INTO OUTFILE '/tmp/know.csv'
#	FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
#	ESCAPED BY '\\'
#	LINES TERMINATED BY '\n'
	from onet.knowledge as know
			inner join
		 onet.content_model_reference as model
			on know.element_id = model.element_id
			inner join
		 onet.scales_reference scale
			on know.scale_id = scale.scale_id
			inner join
		 onet.occupation_data occupation
			on occupation.onetsoc_code = know.onetsoc_code
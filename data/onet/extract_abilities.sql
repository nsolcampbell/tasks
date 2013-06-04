select 'Abilities' as Dimension,
	occupation.onetsoc_code,
	occupation.title,
	occupation.description as job_desc,
	model.element_name, 
	model.description as element_desc,
	abil.data_value, scale.scale_name,
	abil.n, abil.lower_ci_bound, abil.upper_ci_bound
#	INTO OUTFILE '/tmp/know.csv'
#	FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
#	ESCAPED BY '\\'
#	LINES TERMINATED BY '\n'
	from onet.abilities as abil
			inner join
		 onet.content_model_reference as model
			on abil.element_id = model.element_id
			inner join
		 onet.scales_reference scale
			on abil.scale_id = scale.scale_id
			inner join
		 onet.occupation_data occupation
			on occupation.onetsoc_code = abil.onetsoc_code;

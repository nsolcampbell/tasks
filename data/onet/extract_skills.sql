select 
	occupation.*,
	model.element_name, model.description,
	skill.data_value, scale.minimum, scale.maximum, scale.scale_name,
	skill.n, skill.lower_ci_bound, skill.upper_ci_bound
#	INTO OUTFILE '/tmp/occup.csv'
#	FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
#	ESCAPED BY '\\'
#	LINES TERMINATED BY '\n'
	from onet.skills as skill
			inner join
		 onet.content_model_reference as model
			on skill.element_id = model.element_id
			inner join
		 onet.scales_reference scale
			on skill.scale_id = scale.scale_id
			inner join
		 onet.occupation_data occupation
			on occupation.onetsoc_code = skill.onetsoc_code
where occupation.title = 'Education Administrators, Postsecondary';

select * 
	INTO OUTFILE '/tmp/model.csv'
	FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
	ESCAPED BY '\\'
	LINES TERMINATED BY '\n'
from
(select 'Skills' as Dimension,
	occupation.onetsoc_code,
	occupation.title,
	model.element_name, 
	skill.data_value, scale.minimum, scale.maximum, scale.scale_name,
	skill.n, skill.lower_ci_bound, skill.upper_ci_bound
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
union all
select 'Knowledge' as Dimension,
	occupation.onetsoc_code,
	occupation.title,
	model.element_name, 
	know.data_value, scale.minimum, scale.maximum, scale.scale_name,
	know.n, know.lower_ci_bound, know.upper_ci_bound
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
union all
select 'Abilities' as Dimension,
	occupation.onetsoc_code,
	occupation.title,
	model.element_name, 
	abil.data_value, scale.minimum, scale.maximum, scale.scale_name,
	abil.n, abil.lower_ci_bound, abil.upper_ci_bound
	from onet.abilities as abil
			inner join
		 onet.content_model_reference as model
			on abil.element_id = model.element_id
			inner join
		 onet.scales_reference scale
			on abil.scale_id = scale.scale_id
			inner join
		 onet.occupation_data occupation
			on occupation.onetsoc_code = abil.onetsoc_code
union all
select 'Work Activity' as Dimension,
	occupation.onetsoc_code,
	occupation.title,
	model.element_name, 
	act.data_value, scale.minimum, scale.maximum, scale.scale_name,
	act.n, act.lower_ci_bound, act.upper_ci_bound
	from onet.work_activities as act
			inner join 
		 onet.content_model_reference as model
			on act.element_id = model.element_id
			inner join
		 onet.scales_reference scale
			on act.scale_id = scale.scale_id
			inner join
		 onet.occupation_data occupation
			on occupation.onetsoc_code = act.onetsoc_code
) as know_skill_abil;
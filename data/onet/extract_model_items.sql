select distinct * 
	INTO OUTFILE '/tmp/model_items.csv'
	FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
	ESCAPED BY '\\'
	LINES TERMINATED BY '\n'
from
(select 'Skills' as Dimension,
    model.element_id,
	model.element_name, 
	model.description as element_desc
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
    model.element_id,
	model.element_name, 
	model.description as element_desc
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
    model.element_id,
	model.element_name, 
	model.description as element_desc
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
    model.element_id,
	model.element_name, 
	model.description as element_desc
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
-- 1. Which month has the highest count of valid users created?
-- 	A valid user is defined as:
-- 		Has a Non-Block email address
-- 		Has User ID
-- 		Neither the first name nor last name includes “test”
with valid_email as (
	select
		user_id
	from email
	where 
		1=1
		and lower(hashed_email) not like '%blockreno%'
),
valid_contact as (
	select
		user_id
	from contact
	where
		1=1
		and user_id is not null
		and lower(first_name) not like '%test%'
		and lower(last_name) not like '%test%'
)
select 
	date_trunc('month',create_date),
	count(u.user_id)
from block_user u
	inner join valid_email e on u.user_id = e.user_id
	inner join valid_contact c on u.user_id = c.user_id	
group by 1
order by 2 desc;

-- 2. Which month brought in the highest gross deal value?
select
	date_trunc('month',closed_won_date),
	sum(deal_value_usd)
from deal
where
	1=1
	and closed_won_date is not null
group by 1
order by 2 desc

-- 3. What percentage of “closed won” deals does each city account for?
--     We’ll define a “close won” deal as one that:
--         Has an assigned closed, won date
--         Has a valid user (use same criteria as question #1)
with valid_deal as (
	select
		contact_id,
		dc.deal_id
	from deal d
	inner join deal_contact dc on d.deal_id = dc.deal_id 
	where
		1=1
		and closed_won_date is not null
),
valid_email as (
	select
		user_id
	from email
	where 
		1=1
		and lower(hashed_email) not like '%blockreno%'
)
select
	lower(property_city),
	count(distinct d.deal_id),
	(count(distinct d.deal_id)/sum(count(distinct d.deal_id)) over()) as "% of total"
from contact c 
	inner join valid_deal d on c.contact_id = d.contact_id
	inner join valid_email e on c.user_id = e.user_id
where
	1=1
	and c.user_id is not null
	and lower(first_name) not like '%test%'
	and lower(last_name) not like '%test%'
group by 1
order by 2 desc;

-- How much quarterly business has each Source generated for Block? 
-- Which sources are performing above or below their historical monthly benchmarks?

with valid_deal as (
	select
		contact_id,
		dc.deal_id,
		closed_won_date,
		deal_value_usd
	from deal d
	inner join deal_contact dc on d.deal_id = dc.deal_id 
	where
		1=1
		and closed_won_date is not null
),
valid_email as (
	select
		user_id
	from email
	where 
		1=1
		and lower(hashed_email) not like '%blockreno%'
)
select
	date_trunc('month', closed_won_date),
	date_trunc('quarter', closed_won_date),
	property_utm_source,
	property_hdyh,
	count(distinct d.deal_id),
	sum(deal_value_usd)
from contact c 
	inner join valid_deal d on c.contact_id = d.contact_id
	inner join valid_email e on c.user_id = e.user_id
where
	1=1
	and c.user_id is not null
	and lower(first_name) not like '%test%'
	and lower(last_name) not like '%test%'
group by 1,2,3,4
order by 1,2,3,4

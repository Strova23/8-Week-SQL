# all data
select * from plans;
select * from subscriptions;

# organizes tables in a easier way
create temporary table all_data as
	select customer_id
		, plan_name
        , price
        , start_date
	from subscriptions s
	left join plans p on
		p.plan_id = s.plan_id;

select * from all_data;

# Data Analysis

# How many customers has Foodie-Fi ever had?
select count(distinct customer_id) as customers
from all_data;

# What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
select month(start_date) as months
	, count(customer_id) as customers
from all_data
group by months
order by months;

# What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
select plan_name as name
    , count(*) as event_count
from all_data
where start_date >= '2021-01-01'
group by plan_name;

# What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select count(*) as total_customers
	, round(100 * count(*) / (select count(distinct customer_id) from all_data), 1) as churn_percent
from subscriptions
where plan_id = 4;

# How many customers have churned straight after their initial free trial - what percentage is this?
with next_plan as 
(
select *
	, lead(plan_id, 1) over (partition by customer_id order by plan_id) as next_plan
from subscriptions
) 

select count(next_plan)
	, round(count(*) * 100 / (select count(distinct customer_id) from subscriptions), 1) as percentage
from next_plan
where plan_id = 0 and next_plan = 4;

# What is the number and percentage of customer plans after their initial free trial?
with next_plan as 
(
select *
	, lead(plan_id, 1) over (partition by customer_id order by plan_id) as next_plan
from subscriptions
)

select next_plan
	, count(*) as customers
    , round(count(*) * 100 / (select count(distinct customer_id) from subscriptions), 1) as percentage
from next_plan
where plan_id = 0 and next_plan is not null
group by next_plan;

# What is the customer count and percentage breakdown of all 5 plan_name values throughout 2020?
with next_plan_date as 
(
select *
	, lead(plan_id, 1) over (partition by customer_id) as next_plan_date
from subscriptions
where year(start_date) = 2020
)

select plan_name
	, count(*) as customers
	, round(count(*) * 100 / (select count(distinct customer_id) from subscriptions), 1) as perc_of_total
from next_plan_date npd
join plans p on
	npd.plan_id = p.plan_id
group by npd.plan_id, p.plan_name;

# How many customers have upgraded to an annual plan in 2020?
select count(distinct customer_id) as annual_customers
from subscriptions
where plan_id = 3 and year(start_date) = 2020;

# How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
with annual as 
(
select customer_id
	, start_date as annual_start
from subscriptions
where plan_id = 3
) , 
trial as 
(
select customer_id
	, start_date as trial_start
from subscriptions
where plan_id = 0
)

select round(avg(datediff(annual_start, trial_start)), 0) as avg_days_until_annual
from annual a
join trial t on
	a.customer_id = t.customer_id;

# How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
with pmonth as 
(
select customer_id
	, start_date as pmonth_start
from subscriptions
where plan_id = 2 and year(start_date) = 2020
) , 
bmonth as 
(
select customer_id
	, start_date as bmonth_start
from subscriptions
where plan_id = 1 and year(start_date) = 2020
)
select count(distinct b.customer_id) as customers
from bmonth b 
join pmonth p on
	b.customer_id = p.customer_id
where bmonth_start > pmonth_start;
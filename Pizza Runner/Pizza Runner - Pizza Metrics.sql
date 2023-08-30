# all data
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_orders;
select * from runners;
select * from new_runner_orders;
select * from new_customer_orders;

# Cleaning up data
# removing inaccurate, inconsistent, and null values
drop temporary table if exists new_runner_orders;
create temporary table new_runner_orders (
select order_id
	, runner_id
    , case when pickup_time like '%null%' then null
		else pickup_time end as pickup_time
	, case when distance like '%null%' then null
		when distance like '%km%' then trim('km' from distance)
		else distance end as distance
	, case when duration like '%null' then null
		when duration like '%minutes%' then trim('minutes' from duration)
		when duration like '%mins%' then trim('mins' from duration)
        when duration like '%minute%' then trim('minute' from duration)
        else duration end as duration
	, case when cancellation is null then null
		when cancellation like '%null%' then null
        when cancellation = '' then null
        else cancellation end as cancellation
	from runner_orders
    );

drop temporary table if exists new_customer_orders;
create temporary table new_customer_orders (
select order_id
	, customer_id
    , pizza_id
    , case when exclusions like '%null%' then null
		when exclusions = '' then null
		else exclusions
        end as exclusions
	, case when extras is null or extras like '%null%' then null
		when extras = '' then null
		else extras
        end as extras
	, order_time
from customer_orders
);

alter table new_runner_orders
modify column pickup_time datetime,
modify column distance float,
modify column duration int;

# Pizza Metrics

# How many pizzas were ordered?
select count(pizza_id) as "Pizza's Ordered"
from new_customer_orders;

# How many unique customer orders were made?
select count(distinct customer_id) as customers
from new_customer_orders;

# How many successful orders were delivered by each runner?
select runner_id
	, count(order_id) as successful_orders
from new_runner_orders
where cancellation is null
group by runner_id;

# How many of each type of pizza was delivered?
select p.pizza_name
	, count(co.pizza_id) as delivered
from new_customer_orders co
join new_runner_orders ro on
	co.order_id = ro.order_id
join pizza_names p on
	p.pizza_id = co.pizza_id
where cancellation is null
group by pizza_name;

# How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id
	, sum(if(pizza_id = 1, 1, 0)) as meatlovers
    , sum(if(pizza_id = 2, 1, 0)) as vegetarian
from new_customer_orders
group by customer_id;

# What was the maximum number of pizzas delivered in a single order?
with max_pizza as 
( 
select co.order_id
	, count(pizza_id) as pizzas
from new_customer_orders co 
join new_runner_orders ro on
	co.order_id = ro.order_id
where cancellation is null
group by order_id
)
select max(pizzas) as max_pizzas
from max_pizza;

# For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id
	, sum(if(exclusions != '' or extras != '', 1, 0)) as atleast_1_change
    , sum(if(exclusions = '' and extras = '', 1, 0)) as no_changes
from new_customer_orders co
join new_runner_orders ro on
	ro.order_id = co.order_id
where cancellation = ''
group by customer_id;

# How many pizzas were delivered that had both exclusions and extras?
select count(pizza_id) as "Pizza's w/ changes"
from new_customer_orders co
join new_runner_orders ro on
	ro.order_id = co.order_id
where cancellation is null and
	exclusions is not null and
    extras is not null;

# What was the total volume of pizzas ordered for each hour of the day?
select hour(order_time) as day_of_hour
	, count(order_id) as orders
from new_customer_orders
group by day_of_hour
order by day_of_hour;

# What was the volume of orders for each day of the week?
select dayname(order_time) as weekday
	, count(order_id) as orders
from new_customer_orders
group by weekday;
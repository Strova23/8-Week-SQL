# all data
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_orders;
select * from runners;
select * from new_customer_orders;
select * from new_runner_orders;

# If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
with prices as 
(
select pn.pizza_name as pizza
	, case when pn.pizza_name = 'Meatlovers' then 12
		when pn.pizza_name = 'Vegetarian' then 10
        end as price
from new_customer_orders co
join pizza_names pn on
	co.pizza_id = pn.pizza_id
join new_runner_orders ro on
	co.order_id = ro.order_id
where cancellation is null
)

select sum(price) as total
from prices;

# What if there was an additional $1 charge for any pizza extras?
with prices as 
(
select co.pizza_id as pizza
	, sum(case when co.pizza_id = 1 then 12
		when co.pizza_id = 2 then 10
        end) as price
from new_customer_orders co
join new_runner_orders ro on
	co.order_id = ro.order_id
where cancellation is null
),
	changes as 
(
select (length(group_concat(co.extras)) - length(replace(group_concat(co.extras), ',', '')) + 1) as total_changes_price
from new_customer_orders co
)

select total_changes_price + sum(prices) as total_price
from changes, prices;

# can't reopen table -- need to create workaround. 

# If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - 
#	how much money does Pizza Runner have left over after these deliveries?
select round((138 - sum(duration)*0.3), 0) as profit
from new_runner_orders;

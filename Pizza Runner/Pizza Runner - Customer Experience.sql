# all data
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_orders;
select * from runners;
select * from new_customer_orders;
select * from new_runner_orders;

desc new_customer_orders;
desc new_runner_orders;

alter table new_customer_orders
modify column order_time datetime;

# Customer / Runner Experience 

# What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select runner_id
	, round(avg(minute(time(co.order_time) - time(ro.pickup_time))), 0) as "avg arrival time (in mins)"
from new_runner_orders ro 
join new_customer_orders co on
	co.order_id = ro.order_id
group by runner_id;

# Is there any relationship between the number of pizzas and how long the order takes to prepare?
with pizza as 
(
select co.order_id
	, count(pizza_id) as pizzas
    , co.order_time
    , ro.pickup_time
    , timestampdiff(minute, co.order_time, ro.pickup_time) as time_diff
from new_customer_orders co 
join new_runner_orders ro on
	co.order_id = ro.order_id
where cancellation is null
group by co.order_id, co.order_time, ro.pickup_time
)

select pizzas
	, round(avg(time_diff), 0) as average_time
from pizza
group by pizzas
order by pizzas;

# What was the average distance travelled for each customer?
select customer_id
	, round(avg(distance), 0) as avg_distance
from new_customer_orders co
join new_runner_orders ro on
	co.order_id = ro.order_id
where cancellation is null
group by customer_id;

# What was the difference between the longest and shortest delivery times for all orders?
select max(duration) as longest
	, min(duration) as shortest
    , max(duration) - min(duration) as difference
from new_runner_orders;

# What was the average speed for each runner for each delivery and do you notice any trend for these values?
# speed = distance / duration
select runner_id
    , round(avg(60 * distance / duration), 0) as "speed (km/h)"
from new_runner_orders
group by runner_id;


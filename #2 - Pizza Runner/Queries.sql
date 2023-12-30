# all data
select *
from customer_orders;

select *
from pizza_names;

select *
from pizza_recipes;

select * 
from pizza_toppings;

select *
from runner_orders;

select *
from runners;

# Pizza Metrics

# How many pizzas were ordered?
# How many unique customer orders were made?
# How many successful orders were delivered by each runner?
# How many of each type of pizza was delivered?
# How many Vegetarian and Meatlovers were ordered by each customer?
# What was the maximum number of pizzas delivered in a single order?
# For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
# How many pizzas were delivered that had both exclusions and extras?
# What was the total volume of pizzas ordered for each hour of the day?
# What was the volume of orders for each day of the week?

# Customer / Runner Experience 

# How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
# What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
# Is there any relationship between the number of pizzas and how long the order takes to prepare?
# What was the average distance travelled for each customer?
# What was the difference between the longest and shortest delivery times for all orders?
# What was the average speed for each runner for each delivery and do you notice any trend for these values?
# What is the successful delivery percentage for each runner?

# Ingredients Optimization

# What are the standard ingredients for each pizza?
# What was the most commonly added extra?
# What was the most common exclusion?
#Generate an order item for each record in the customers_orders table in the format of one of the following:
# 	Meat Lovers
# 	Meat Lovers - Exclude Beef
# 	Meat Lovers - Extra Bacon
# 	Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
# Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
# What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
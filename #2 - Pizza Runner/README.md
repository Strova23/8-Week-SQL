# 🍕 Pizza Runner

<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" width="700">

All information and questions for this Case Study are located [**here**](https://8weeksqlchallenge.com/case-study-2/)

## ❓Problem Statement ❓

Danny was sold on the idea to start selling 80s Retro Style Pizza, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny has began recruiting "Pizza Runners" to deliver fresh pizza straight from headquarters (Danny's house). He has maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers. Danny understands that data collection and analysis are going to be critical if he wants his Pizza Empire to succeed, so he needs help cleaning his data and doing analysis so he can better direct his runners and optimize Pizza Runner's operations. 

**Danny has prepared for us an entity relationship diagram of his database:**

<img src="https://i.gyazo.com/caab0f20cf0cb0e5d8a9b2683f2d2756.png">

## 💧Data Cleaning and Transformation
A lot of the data provided has null values or empty values for columns that aren't consistent with the entire row/column. We must first do some simple queries to clean the data Danny provided us and make sure all our data is consistent. 

**Updating runner_orders**
```sql
create temporary table new_runner_orders
(
select
  order_id,
  runner_id,
  case
    when pickup_time like '%null%' then null
		else pickup_time end as pickup_time,
  case
    when distance like '%null%' then null
		when distance like '%km%' then trim('km' from distance)
		else distance end as distance,
	case
    when duration like '%null' then null
		when duration like '%minutes%' then trim('minutes' from duration)
		when duration like '%mins%' then trim('mins' from duration)
    when duration like '%minute%' then trim('minute' from duration)
    else duration end as duration,
  case
    when cancellation is null then null
		when cancellation like '%null%' then null
    when cancellation = '' then null
    else cancellation end as cancellation
	from runner_orders

alter table new_runner_orders
  modify column pickup_time datetime,
  modify column distance float,
  modify column duration int;
);
```

**Updating customer_orders**
```sql
create temporary table new_customer_orders
(
select
  order_id,
	customer_id,
  pizza_id,
  case
    when exclusions like '%null%' then null
		when exclusions = '' then null
		else exclusions end as exclusions,
	case
    when extras is null or extras like '%null%' then null
		when extras = '' then null
		else extras end as extras,
	order_time
from customer_orders
);
```

## 💡 Case Study Questions

### 📺 Pizza Metrics
1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

[**SOLUTION**](https://github.com/Strova23/8-Week-SQL/blob/main/%232%20-%20Pizza%20Runner/Pizza%20Metrics.md)

### 🧍 Runner and Customer Experience
1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?\

**SOLUTION**

### 💰 Price Analysis
1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras?
- Add cheese is $1 extra
3. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

**SOLUTION**

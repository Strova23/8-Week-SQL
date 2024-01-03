# 📺 Pizza Metrics

**1. How many pizzas were ordered?**
```sql
select
  count(pizza_id) as "Pizza's Ordered"
from new_customer_orders;
```
**Solution:**
| Pizza's Ordered |
|-|
|14|

**2. How many unique customer orders were made?**
```sql
select
  count(distinct order_id) as customers
from new_customer_orders;
```
**Solution:**
| Customers |
|-|
|10|

**3. How many successful orders were delivered by each runner?**
```sql
select
  runner_id,
	count(order_id) as successful_orders
from new_runner_orders
where cancellation is null
group by runner_id;
```
**Solution:**
| runner_id | successful_order |
| - | - |
|1|4|
|2|3|
|3|1|

**4. How many of each type of pizza was delivered?**
```sql
select
  p.pizza_name,
	count(co.pizza_id) as delivered
from new_customer_orders co
join new_runner_orders ro on
	co.order_id = ro.order_id
join pizza_names p on
	p.pizza_id = co.pizza_id
where cancellation is null
group by pizza_name;
```
**Solution:**
|pizza_name|delivered|
|-|-|
|Meatlovers|9|
|Vegetarian|3|

**5. How many Vegetarian and Meatlovers were ordered by each customer?**
```sql
select
  customer_id,
	sum(if(pizza_id = 1, 1, 0)) as meatlovers,
  sum(if(pizza_id = 2, 1, 0)) as vegetarian
from new_customer_orders
group by customer_id;
```
**Solution:**
|customer_id|meatlovers|vegetarian|
|-|-|-|
|101|2|1|
|102|2|1|
|103|3|1|
|104|3|0|
|105|0|1|

**6. What was the maximum number of pizzas delivered in a single order?**
```sql
with max_pizza as 
( 
select
  co.order_id,
  count(pizza_id) as pizzas
from new_customer_orders co 
join new_runner_orders ro on
	co.order_id = ro.order_id
where cancellation is null
group by order_id
)
select
  max(pizzas) as max_pizzas
from max_pizza;
```
**Solution:**
|max_pizzas|
|-|
|3|

**7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
```sql
select
  customer_id,
	sum(if(exclusions != '' or extras != '', 1, 0)) as atleast_1_change,
  sum(if(exclusions = '' and extras = '', 1, 0)) as no_changes
from new_customer_orders co
join new_runner_orders ro on
	ro.order_id = co.order_id
where cancellation = ''
group by customer_id;
```
**Solution:**
|customer_id|atleast_1_change|no_changes|
|-|-|-|
|101|0|2|
|102|0|3|
|103|3|0|
|104|2|1|
|105|1|0|

**8. How many pizzas were delivered that had both exclusions and extras?**
```sql
select
  count(pizza_id) as "Pizza's w/ changes"
from new_customer_orders co
join new_runner_orders ro on
	ro.order_id = co.order_id
where cancellation is null
  and exclusions is not null
  and extras is not null;
```
**Solution:**
|Pizza's w/ changes|
|-|
|1|

**9. What was the total volume of pizzas ordered for each hour of the day?**
```sql
select
  hour(order_time) as hour_of_day,
	count(order_id) as orders
from new_customer_orders
group by day_of_hour
order by day_of_hour;
```
**Solution:**
|hour_of_day|orders|
|-|-|
|11 AM|1|
|1 PM|3|
|5 PM|3|
|6 PM|1|
|9 PM|3|
|11 PM|3|

**10. What was the volume of orders for each day of the week?**
```sql
select
  dayname(order_time) as weekday,
	count(order_id) as orders
from new_customer_orders
group by weekday;
```
**Solution:**
|weekday|orders|
|-|-|
|Wednesday|5|
|Thursday|3|
|Saturday|5|
|Friday|1|

# 🧍 Customer and Runner Experience

**1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**
```sql
select
  datepart(week, registration_date) as registration_week,
  count(runner_id) AS signups
from runners
group by datepart(week, registration_date);
```
**Solution:**
|registration_week|signups|
|-|-|
|1|2|
|2|1|
|3|1|

**2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```sql
select
  runner_id,
	round(avg(minute(time(co.order_time) - time(ro.pickup_time))), 0) as "avg arrival time (in mins)"
from new_runner_orders ro 
join new_customer_orders co on
	co.order_id = ro.order_id
group by runner_id;
```
**Solution:**
|runner_id|avg arrival time (in mins)|
|-|-|
|1|10|
|2|27|
|3|10|

**3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**

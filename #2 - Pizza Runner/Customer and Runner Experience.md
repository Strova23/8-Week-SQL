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
```sql
with pizza as 
(
select
  co.order_id,
  count(pizza_id) as pizzas,
  co.order_time,
  ro.pickup_time,
  timestampdiff(minute, co.order_time, ro.pickup_time) as time_diff
from new_customer_orders co 
join new_runner_orders ro on
  co.order_id = ro.order_id
where cancellation is null
group by co.order_id, co.order_time, ro.pickup_time
)
select
  pizzas,
  round(avg(time_diff), 0) as average_time
from pizza
group by pizzas
order by pizzas;
```
**Solution:**
|pizzas|average_time|
|-|-|
|1|12|
|2|18|
|3|29|

**4. What was the average distance travelled for each customer?**
```sql
select
  customer_id,
  round(avg(distance), 0) as avg_distance
from new_customer_orders co
join new_runner_orders ro on
  co.order_id = ro.order_id
where cancellation is null
group by customer_id;
```
**Solution**
|customer_id|avg_distance|
|-|-|
|101|20|
|102|17|
|103|23|
|104|10|
|105|25|

**5. What was the difference between the longest and shortest delivery times for all orders?**

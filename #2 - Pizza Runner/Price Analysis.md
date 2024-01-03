# 💰Price Analysis
**1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**
```sql
with prices as 
(
select
  pn.pizza_name as pizza,
	case
    when pn.pizza_name = 'Meatlovers' then 12
    when pn.pizza_name = 'Vegetarian' then 10
    end as price
from new_customer_orders co
join pizza_names pn on
	co.pizza_id = pn.pizza_id
join new_runner_orders ro on
	co.order_id = ro.order_id
where cancellation is null
)
select
  sum(price) as total
from prices;
```
**Solution:**
|total|
|-|
|138|

**2. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?**
```sql
select
  round((138 - sum(duration)*0.3), 0) as profit
from new_runner_orders;
```
**Solution:**
|profit|
|-|
|83|

### 🧍[Customer and Runner Experience](https://github.com/Strova23/8-Week-SQL/blob/main/%232%20-%20Pizza%20Runner/Customer%20and%20Runner%20Experience.md)
### 📺[Pizza Metrics](https://github.com/Strova23/8-Week-SQL/blob/main/%232%20-%20Pizza%20Runner/Pizza%20Metrics.md)

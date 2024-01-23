# 📓Data Analysis Questions

**1. How many customers has Foodie-Fi ever had?**
```sql
select
  count(distinct customer_id) as customers
from all_data;
```
**Solution:**
|customer|
|-|
|1000|

**2.  What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value**
```sql
select 
  month(start_date) as months,
  count(customer_id) as customers
from all_data
where plan_id = 0
group by months
order by months;
```
**Solution:**
|months|customers|
|-|-|
|1|88|
|2|68|
|3|94|
|4|81|
|5|88|
|6|79|
|7|89|
|8|88|
|9|87|
|10|79|
|11|75|
|12|84|

**3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name**
```sql
select
  plan_name as name,
  count(*) as event_count
from all_data
where start_date >= '2021-01-01'
group by plan_name;
```
**Solution:**
|name|event_count|
|-|-|
|churn|71|
|pro monthly|60|
|pro annual|63|
|basic monthly|8|

**4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**
```sql
select
  count(*) as total_customers,
  round(100 * count(*) / (select count(distinct customer_id) from all_data), 1) as churn_percent
from subscriptions
where plan_id = 4;
```
**Solution:**
|total_customers|churn_percent|
|-|-|
|307|30.7|

**5. How many customers have churned straight after their initial free trial - what percentage is this?**

- Create a CTE to hold the next trial
- Use a WHERE clause to filter only the customers whose next plan was "Churn" (id = 4) with previous plan being the free trial (id = 0)

```sql
with next_plan as 
(
select
  *,
  lead(plan_id, 1) over (partition by customer_id order by plan_id) as next_plan
from subscriptions
) 

select
  count(next_plan) as churn_count,
  round(count(*) * 100 / (select count(distinct customer_id) from subscriptions), 1) as percentage
from next_plan
where plan_id = 0 and next_plan = 4;
```
**Solution:**
|churn_count|percentage|
|-|-|
|92|9.2|

**6. What is the number and percentage of customer plans after their initial free trial?**

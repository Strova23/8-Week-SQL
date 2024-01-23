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
|churn_count|percentage(%)|
|-|-|
|92|9.2|

**6. What is the number and percentage of customer plans after their initial free trial?**

- Use the same CTE to hold the plans/trials after the free trial
- Change the WHERE filter to simply include any trial
- Group by the next_plans

```sql 
with next_plan as 
(
select
  *,
  lead(plan_id, 1) over (partition by customer_id order by plan_id) as next_plan
from subscriptions
)

select
  next_plan,
  count(*) as customers,
  round(count(*) * 100 / (select count(distinct customer_id) from subscriptions), 1) as percentage
from next_plan
where plan_id = 0 and next_plan is not null
group by next_plan;
```
**Solution:** 
|next_plan|customers|percentage(%)|
|-|-|-|
|1|546|54.6|
|2|325|32.5|
|3|37|3.7|
|4|92|9.2|

**7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**

- Use CTE to filter all plans with start dates before 2020-12-31 (next_plan_date serves as the next plans)
- Using the "next_plan_date is null" filter, we get the last remaining plan each customer had before 2020-12-31

```sql
with next_plan_date as 
(
select *
	, lead(start_date) over (partition by customer_id) as next_plan_date
from subscriptions
where start_date <= '2020-12-31'
)

select plan_name
	, count(*) as customers
	, round(count(*) * 100 / (select count(distinct customer_id) from subscriptions), 1) as perc_of_total
from next_plan_date npd
join plans p on
	npd.plan_id = p.plan_id
where next_plan_date is null
group by npd.plan_id, p.plan_name;
```
**Solution:**
|plan_name|customers|perc_of_total|
|-|-|-|
|trial|19|1.9|
|basic monthly|224|22.4|
|pro monthly|326|32.6|
|pro annual|195|19.5|
|churn|236|23.6|

**8. How many customers have upgraded to an annual plan in 2020?**
```sql
select count(distinct customer_id) as annual_customers
from subscriptions
where plan_id = 3 and year(start_date) = 2020;
```
**Solution:**
|annual_customers|
|-|
|195|

**9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?**

- 2 separate CTEs. One holds when a customer first joined, the other holds when(or if) they upgraded to an annual plan.
- Find the avg of the 2 after joining the CTEs

```sql
with annual as 
(
select
  customer_id,
	start_date as annual_start
from subscriptions
where plan_id = 3
) , 
trial as 
(
select
  customer_id,
	start_date as trial_start
from subscriptions
where plan_id = 0
)

select
  round(avg(datediff(annual_start, trial_start)), 0) as avg_days_until_annual
from annual a
join trial t on
	a.customer_id = t.customer_id;
```
**Solution:**
|avg_days_until_upgrade|
|-|
|105|

**10. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**

- Use 2 CTEs. One to hold when the customer had a pro monthly trial. The other holds when the customer had a basic monthly plan
- Downgrades happen when the start_date for the basic monthly plan is after the pro monthly plan.

```sql
with pmonth as 
(
select
  customer_id,
	start_date as pmonth_start
from subscriptions
where plan_id = 2 and year(start_date) = 2020
) , 
bmonth as 
(
select
  customer_id,
	start_date as bmonth_start
from subscriptions
where plan_id = 1 and year(start_date) = 2020
)
select
  count(distinct b.customer_id) as customers
from bmonth b 
join pmonth p on
	b.customer_id = p.customer_id
where bmonth_start > pmonth_start;
```
**Solution:**
|customers|
|-|
|0|

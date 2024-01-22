# 🥘Foodie-Fi

<img src="https://8weeksqlchallenge.com/images/case-study-designs/3.png" width="700">

All information and questions for this Case Study are located [**here**](https://8weeksqlchallenge.com/case-study-3/)

## ❓Problem Statement❓

Danny wanted to create a new streaming service that only has food-related content. He created Foodie-Fi to give customers unlimited on-demand access to exclusive food videos from around the world! However, now he wants to ensure that all future investment decisions and new features are decided using data-driven decisions. Can you help him use his subscription based digital data to make important business changes that can improve Foodie-Fi

**Relationship Diagram Data**

<img src="https://i.gyazo.com/a9472ead2139fab73dc6b7a7cd461055.png">

## Table Transformation
We can join both tables together to create a better image of the journey each customer has gone through and when they upgraded to each plan. 

```sql
create temporary table all_data as
select
  customer_id,
  plan_name,
  price,
  start_date
from subscriptions s
left join plans p on
  p.plan_id = s.plan_id;
```

## 📓Data Analysis Questions
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

[**SOLUTION**](https://github.com/Strova23/8-Week-SQL/blob/main/%233%20-%20Foodie-Fi/Data%20Analysis.md)

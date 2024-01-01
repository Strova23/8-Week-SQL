# 💡 Case Study Questions

**1. What is the total amount each customer spent at the restaurant?**

**Thoughts:**
- need to use GROUP BY on the primary key (```customer_id```)
- merge ```sales``` and ```menu``` table together to create a table that includes both ```customer_id``` and ```price```

```sql
select
  customer_id as customer,
  sum(price) as money_spent
from sales s
join menu m on 
	s.product_id = m.product_id
group by customer_id;
```

**Solution:**

| customer | money_spent | 
| -------- | ----------- |
| A        | 76          |
| B        | 74          | 
| C        | 36          | 

Customer A spent $76 <br>
Customer B spent $74 <br>
Customer C spent $36

**2. How many days has each customer visited the restaurant?**

**Thoughts:**
- GROUP BY the unique primary key (```customer_id```)
- COUNT each **UNIQUE** day a customer came

```sql
select
  customer_id as customer,
  count(distinct order_date) as "visit_days"
from sales s
group by customer_id;
```

**Solution:**

| customer | visit_days |
|----|----|
| A | 4 |
| B | 6 | 
| C | 2 |

Customer A visited 4 times <br>
Customer B visited 6 times <br>
Customer C visited 2 times

**3. What was the first item from the menu purchased by each customer?**

**Thoughts:** 
- Filter each customer and only select the item that corresponds with the earliest ```order_date```
```sql
select
  distinct customer_id as customer,
  m.product_id as item,
  m.product_name as name,
  order_date as "Date"
from sales s 
join menu m on
	s.product_id = m.product_id
where order_date = (select min(order_date) from sales);
```

OR

- create a CTE expression and use the _dense_rank()_ function to order the ```order_date```
- retrieve only the first rows where the rank = 1

```sql
with rk as
(
select
  s.customer_id,
  m.product_name,
  s.order_date,
  dense_rank() over (partition by s.customer_id order by s.order_date) as rk
from menu m
join sales s on
	m.product_id = s.product_id
group by s.customer_id, m.product_name, s.order_date
)

select
  customer_id as customer,
  product_name as name
from rk
where rk = 1;
```

**Solution:**
- filtering by earliest ```order_date```

| customer | item | name | Date |
| -- | --| -- | -- |
| A | 1 | sushi | 2021-01-01|
| B | 2 | curry | 2021-01-01|
| A | 2 | curry | 2021-01-01|
| C | 3 | ramen | 2021-01-01|

- using CTE

| customer | name |
|- | -|
| A | sushi |
| A | curry | 
| B | curry | 
| C | ramen |

Customer A's first order was both sushi and curry <br>
Customer B's first order was curry <br>
Customer C's first order was ramen

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

**Thoughts:**
- COUNT how many times each product was ordered
- ORDER BY descending order
- LIMIT 1

```sql
select
  m.product_name as product,
  count(s.product_id) as amount
from menu m
join sales s on
  s.product_id = m.product_id
group by m.product_name
order by count(s.product_id) desc limit 1;
```

**Solution:**
| product | amount |
| - | - |
| ramen | 8 |

The most purchased item on the menu was ramen, which was purchased 8 times. 

**5. Which item was the most popular for each customer?**

**Thoughts:**
- create a CTE using _dense_rank()_ partitioning by each customer to determine how many times they ordered each menu item
- ORDER BY desc, LIMIT 1
- GROUP BY ```customer_id``` and ```product_name```

```sql
with rk as 
(
select
  s.customer_id,
  m.product_name,
  count(s.product_id) as amount,
  dense_rank() over (partition by s.customer_id order by count(s.product_id) desc) as rk
from menu m
join sales s on
  s.product_id = m.product_id
group by s.customer_id, m.product_name
)

select customer_id as customer, product_name as name, amount
from rk
where rk = 1;
```

**Solution:**
| customer | name | amount |
| - | - | - |
| A | ramen | 3 | 
| B | curry | 2 | 
| B | sushi | 2 | 
| B | ramen | 2 |
| C | ramen | 3 |

Customer A's favorite item was ramen <br>
Customer C's favorite item was also ramen <br>
Customer B enjoyed all the items equally

**6. Which item was purchased first by the customer after they became a member?**

**Thoughts:**
- need to combine all 3 tables (2 joins)
- like the previous questions, create a CTE and use _dense_rank()_ to rank when each item was ordered from earliest to latest
- Add a WHERE clause to filter members by only including orders that are after their ```member.join_date```
- SELECT the first item where the row/rank is 1 as this indicates the first purchase after becoming a member

```sql
with rk as 
(
select
  s.customer_id,
  m.product_name,
  dense_rank() over (partition by customer_id order by order_date) as rk
from sales s
join menu m on
  m.product_id = s.product_id
join members mem on
  s.customer_id = mem.customer_id
where s.order_date >= mem.join_date
)
select
  customer_id as customer,
  product_name as name
from rk
where rk = 1;
```

**Solution:**
| customer | name |
| - | - |
| A | curry |
| B | sushi |

Customer A's first purchase after becoming a member was curry <br>
Customer B's first purchase after becoming a member was sushi <br>
Customer C never became a member therefore he isn't in this table

**7. Which item was purchased just before the customer became a member?**

**Thoughts:**
- use the same CTE as question 6, with some slight changes
- must use the WHERE clause to filter orders that happened before the ```member.join_date```
- must partition and ORDER BY descending order dates, as we are looking to obtain the most recent order prior to becoming a member
- SELECT the item that corresponds to rank 1, this is the latest order. 

```sql
with rk as 
(
select
  s.customer_id,
  m.product_name,
  dense_rank() over (partition by customer_id order by order_date desc) as rk
from sales s
join menu m on
  m.product_id = s.product_id
join members mem on
  s.customer_id = mem.customer_id
where s.order_date < mem.join_date
)

select
  customer_id as customer,
  product_name as name
from rk
where rk = 1;
```

**Solution:**
| customer | name |
| - | - |
| A | sushi |
| A | curry |
| B | sushi |

Before becoming members, 

Customer A's last order was both sushi and curry <br>
Customer B's last order was sushi

**8. What is the total items and amount spent for each member before they became a member?**

**Thoughts:**
- Join all three tables
- filter to only include orders from before the customer was a member (```order_date < member.join_date```)
- COUNT all items purchased
- SUM all the prices
- GROUP BY each customer_id

```sql
select
  s.customer_id as customer,
  count(s.product_id) as total_items,
  sum(price) as total_money_spent
from sales s
join menu m on
  s.product_id = m.product_id
join members mem on
  s.customer_id = mem.customer_id
where s.order_date < mem.join_date
group by s.customer_id
order by s.customer_id;
```

**Solution:**
| customer | total_items | money_spent |
| - | - | - |
| A | 2 | 25 | 
| B | 3 | 40 |

Before becoming members,

Customer A bought 2 items totaling $25 <br>
Customer B bought 3 items totaling $40

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

**Thoughts:**
- Convert all prices to points, $1 = 10 points with sushi being $1 = 20 points
- SUM all points for each customer
- GROUP BY customer_id

```sql
with points as 
(
select
  *,
  case
  when product_id = 1 then price*20
  else price*10
  end as points
from menu
)
select
  s.customer_id as customer,
  sum(points) as points
from sales s
join points p on
  s.product_id = p.product_id
group by customer_id;
```

**Solution:**
| customer | points | 
| - | - |
| A | 860 |
| B | 940 | 
| C | 360 |

Customer A had 860 total points <br>
Customer B had 940 total points <br>
Customer C had 360 total points 

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customers A and B have at the end of January?**

**Thoughts:**
- Cumulative sum until the end of January
- Use _datediff()_ and _between_ to determine a 1 week timeframe between ```member.join_date``` and ```order_date```
- triple join to get all the necessary information in 1 table.
- GROUP BY customer_id

```sql
select
  s.customer_id as customer,
  sum(case
    when datediff(mem.join_date, s.order_date) between 0 and 7 then m.price*20
    when m.product_id = 1 then m.price*20
    else m.price*10
    end) as points
from sales s
join members mem on
  s.customer_id = mem.customer_id
join menu m on
  s.product_id = m.product_id
where s.order_date >= mem.join_date and 
  s.order_date < cast('2021-01-31' as date)
group by s.customer_id
order by s.customer_id;
```

**Solution:**
| customer | points |
| - | - |
| A | 660 | 
| B | 320 |

At the end of January, 

Customer A had 660 total points <br>
Customer B had 320 total points 

# 📁 **BONUS**

**Create a table to include all the necessary data without needing to do any joins**

**Thoughts:**
- Join all 3 tables
- Use CASE WHEN statements to add a separate column that determines if a customer is a member or not.

```sql
select
  s.customer_id,
  s.order_date,
  m.product_name,
  m.price,
  case
    when s.order_date < mem.join_date then 'No'
    else 'Yes'
    end as member
from sales s 
join menu m on
  s.product_id = m.product_id
join members mem on
  s.customer_id = mem.customer_id
order by s.customer_id, s.order_date, m.product_name;
```

**Solution:**

| customer_id | order_date| product_name | price | member |
| ----------- | ----------| ------------ | ----- | -------|
| A           | 2021-01-01| sushi        | 10    | N      |
| A           | 2021-01-01| curry        | 15    | N      |
| A           | 2021-01-07| curry        | 15    | Y      |
| A           | 2021-01-10| ramen        | 12    | Y      |
| A           | 2021-01-11| ramen        | 12    | Y      |
| A           | 2021-01-11| ramen        | 12    | Y      |
| B           | 2021-01-01| curry        | 15    | N      |
| B           | 2021-01-02| curry        | 15    | N      |
| B           | 2021-01-04| sushi        | 10    | N      |
| B           | 2021-01-11| sushi        | 10    | Y      |
| B           | 2021-01-16| ramen        | 12    | Y      |
| B           | 2021-02-01| ramen        | 12    | Y      |
| C           | 2021-01-01| ramen        | 12    | N      |
| C           | 2021-01-01| ramen        | 12    | N      |
| C           | 2021-01-07| ramen        | 12    | N      |

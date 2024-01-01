# 💡 Case Study Questions

**1. What is the total amount each customer spent at the restaurant?**

**Thoughts:**
- need to use 'group by' on the primary key (```customer_id```)
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
- group on the unique primary key (```customer_id```)
- count each **UNIQUE** day a customer came

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
- Count how many times each product was ordered
- Order in descending order
- Limit 1

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

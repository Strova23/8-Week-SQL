# members who joined the "beta" version of Danny's diner 
select *
from members;

# simple table to show what the name and price of each menu item is
select * 
from menu;

# all customers purchaces, with order_date and product_id for when and what menu items were ordered
select *
from sales;

-- 1. What is the total amount each customer spent at the restaurant?
select customer_id as customer
	, sum(price) as "money spent"
from sales s
join menu m on 
	s.product_id = m.product_id
group by customer_id;

-- 2. How many days has each customer visited the restaurant?
select customer_id as customer
	, count(distinct order_date) as "Visit days"
from sales s
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
select distinct customer_id as customer
	, m.product_id as item
    , m.product_name as name
    , order_date as "Date"
from sales s 
join menu m on
	s.product_id = m.product_id
where order_date = (select min(order_date) from sales);

# another solution
with rk as
(
select s.customer_id
	, m.product_name
    , s.order_date
    , dense_rank() over (partition by s.customer_id order by s.order_date) as rk
from menu m
join sales s on
	m.product_id = s.product_id
group by s.customer_id, m.product_name, s.order_date
)

select customer_id as customer
	, product_name as name
from rk
where rk = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
# what is the most popular item on the menu?
select m.product_name as product
	, count(s.product_id) as amount
from menu m
join sales s on
	s.product_id = m.product_id
group by m.product_name
order by count(s.product_id) desc limit 1;

-- 5. Which item was the most popular for each customer?
with rk as 
(
select s.customer_id
	, m.product_name
    , count(s.product_id) as amount
    , dense_rank() over (partition by s.customer_id order by count(s.product_id) desc) as rk
from menu m
join sales s on
	s.product_id = m.product_id
group by s.customer_id, m.product_name
)
select customer_id as customer, product_name as name, amount
from rk
where rk = 1;

-- 6. Which item was purchased first by the customer after they became a member?
with rk as 
(
select s.customer_id
	, m.product_name
	, dense_rank() over (partition by customer_id order by order_date) as rk
from sales s
join menu m on
	m.product_id = s.product_id
join members mem on
	s.customer_id = mem.customer_id
where s.order_date >= mem.join_date
)
select customer_id as customer
	, product_name as name
from rk
where rk = 1;

-- 7. Which item was purchased just before the customer became a member?
select s.customer_id as customer
	, m.product_name as name
from sales s
join menu m on
	m.product_id = s.product_id
join members mem on
	s.customer_id = mem.customer_id
where s.order_date < mem.join_date
order by s.customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id
	, count(s.product_id) as total_items
    , sum(price) as total_money_spent
from sales s
join menu m on
	s.product_id = m.product_id
join members mem on
	s.customer_id = mem.customer_id
where s.order_date < mem.join_date
group by s.customer_id
order by s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with points as 
(
select *
	, case when product_id = 1 then price*20
		else price*10
        end as points
from menu
)
select s.customer_id, sum(points) as points
from sales s
join points p on
	s.product_id = p.product_id
group by customer_id;

select datediff(day, members.join_date, sales.order_date) as date;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select s.customer_id as customer
	, sum(case when datediff(mem.join_date, s.order_date) between 0 and 7 then m.price*20
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

-- Create a table to include all the necessary data without needing to do any joins
select s.customer_id
	, s.order_date
	, m.product_name
    , m.price
    , case when s.order_date < mem.join_date then 'No'
		else 'Yes'
        end as member
from sales s 
join menu m on
	s.product_id = m.product_id
join members mem on
	s.customer_id = mem.customer_id
order by s.customer_id, s.order_date, m.product_name;


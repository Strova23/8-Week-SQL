# ALL DATA
select * from customer_nodes;
select * from customer_transactions;
select * from regions;

# CUSTOMER TRANSACTIONS

# What is the unique count and total amount for each transaction type?
select txn_type as type, 
	count(distinct customer_id) as transactions, 
    sum(txn_amount) as amount
from customer_transactions
group by txn_type;

# What is the average total historical deposit counts and amounts for all customers?
with deposits as 
(
select customer_id, 
	count(txn_type) as Tcounts, 
    sum(txn_amount) as Tamount
from customer_transactions
where txn_type = 'deposit'
group by customer_id
)

select round(avg(Tcounts), 0) as 'avg deposit counts', 
	round(avg(Tamount), 0) as 'avg deposit sum'
from deposits
order by customer_id;

# For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
with Monthly_customer as 
(
select customer_id, 
	month(txn_date) as Month, 
	sum(case when txn_type = 'deposit' then 1 else 0 end) as deposit,
    sum(case when txn_type = 'purchase' then 1 else 0 end) as purchase,
    sum(case when txn_type = 'withdrawal' then 1 else 0 end) as withdrawal
from customer_transactions
group by Month, customer_id
)

select Month, 
	count(customer_id) as customers
from Monthly_customer
where deposit >= 1 and (purchase = 1 or withdrawal = 1)
group by Month;

# What is the closing balance for each customer at the end of the month?
with monthly_sum as 
(
select customer_id, 
	month(txn_date) as Month, 
	sum(case when txn_type = 'deposit' then txn_amount else -txn_amount end) as balance
from customer_transactions
group by Month, customer_id
order by customer_id
)

select customer_id, 
	Month, 
    sum(balance) over (partition by customer_id order by month asc rows between unbounded preceding and current row) as closing_balance
from monthly_sum
group by Month, customer_id
order by customer_id;
# What is the percentage of customers who increase their closing balance by more than 5%?
with monthly_sum as 
(
select customer_id, 
	month(txn_date) as Month, 
	sum(case when txn_type = 'deposit' then txn_amount else -txn_amount end) as balance
from customer_transactions
group by Month, customer_id
order by customer_id
), 
closing as 
(
select customer_id, 
	Month, 
    sum(balance) over (partition by customer_id order by month asc rows between unbounded preceding and current row) as closing_balance
from monthly_sum
group by Month, customer_id
order by customer_id
),
following_months as 
(
select customer_id, 
	Month,
    closing_balance,
    lead(closing_balance) over (partition by customer_id order by month) as following_balance
from closing
), 
percentIncrease as 
(
select * 
from following_months
where following_balance >= 0
group by customer_id, Month, closing_balance, following_balance
having round(100 * (following_balance - closing_balance) / closing_balance, 1) > 5.0
)

select round(100 * count(customer_id) / (select count(distinct customer_id) from monthly_sum), 1) as increase_5_perc
from percentIncrease
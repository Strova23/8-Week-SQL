# ALL DATA
select * from customer_nodes;
select * from customer_transactions;
select * from regions;


# CUSTOMER DATA EXPLORATION

# How many unique nodes are there on the Data Bank system?
select count(distinct node_id)  as unique_nodes
from customer_nodes;

# What is the number of nodes per region?
select region_name 
	, count(node_id) as nodes
from customer_nodes n
join regions r on
	n.region_id = r.region_id
group by region_name;

# How many customers are allocated to each region?
select region_name 
	, count(distinct customer_id) as customers
from customer_nodes n
join regions r on
	n.region_id = r.region_id
group by region_name;

# How many days on average are customers reallocated to a different node?
select distinct start_date from customer_nodes;
select distinct end_date from customer_nodes;

SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;
delete from customer_nodes 
where end_date = '9999-12-31';

select round(avg(datediff(end_date, start_date)), 0) as avg_days
from customer_nodes;

# What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
with region as 
(
select region_name
	, datediff(end_date, start_date) as day_diff
from customer_nodes n
join regions r on 
	n.region_id = r.region_id
)
, 
percentile as 
(
select *
	, row_number() over (partition by region_name order by day_diff) as rn
from region
)

select region_name
	, max(rn) as '100_percentile'
    , round(max(rn) / 2, 0) as median_rn
    , round(max(rn) * 0.8, 0) as '80_percentile row'
    , round(max(rn) * 0.95, 0) as '95_percentile row'
from percentile
group by region_name;

# CUSTOMER TRANSACTIONS

# What is the unique count and total amount for each transaction type?
select txn_type as type, count(distinct customer_id) as transactions, sum(txn_amount) as amount
from customer_transactions
group by txn_type;

# What is the average total historical deposit counts and amounts for all customers?
with deposits as 
(
select customer_id, count(txn_type) as Tcounts, sum(txn_amount) as Tamount
from customer_transactions
where txn_type = 'deposit'
group by customer_id
)

select round(avg(Tcounts), 0) as 'avg deposit counts', round(avg(Tamount), 0) as 'avg deposit sum'
from deposits
order by customer_id

# For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

# What is the closing balance for each customer at the end of the month?

# What is the percentage of customers who increase their closing balance by more than 5%?
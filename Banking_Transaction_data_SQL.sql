create database banking_transaction_data;

create table banking_transaction_data(
Transaction_ID varchar(20),
Customer_ID varchar(89),
Transaction_Date date,
MONTH int,
YEAR int,
Customer_Age int,
Gender varchar(60),
Branch varchar(89),
Account_Type varchar(80),
Transaction_Type varchar(40),
Channel varchar(50),
Amount decimal (2),
Balance_After_Txn decimal(2),
Credit_Score int,
Fraud_Flag varchar(40),
fraud int,
Loan_Status varchar(49),
Customer_Satisfaction int

);
select * from banking_transaction_data;

--1.how many total transaction from each branch

select
Branch,
count(*) as total_transaction
from banking_transaction_data
group by Branch
order by total_transaction desc;

--2.what is the total transaction amount and balance_after_transaction

select sum(amount) as total_transaction_amount,
avg(amount) as avg_balance_after_txn
from banking_transaction_data

--3.what is the total_transaction amount and number of transaction for each branch

select Branch,count(*)as total_member,sum(amount) as total_amount
from banking_transaction_data
group by branch
order by total_amount desc;

--4.Find the top 10 customers based on total transaction amount.

select customer_id,sum(amount)as total_transaction_amount
from banking_transaction_data
group by customer_id
order by total_transaction_amount desc;

--5.Find the number of transactions for each transaction type.

select transaction_type,count(*)as number_of_transactiom
from banking_transaction_data
group by transaction_type

--6.Find customers whose total transaction amount is greater than the overall average transaction amount.

select customer_id,sum(amount)as total_transaction_amount
from banking_transaction_data
group by customer_id
having sum(amount)>(select avg(amount) from banking_transaction_data)
order by total_transaction_amount desc

--7.Find the highest transaction amount for each transaction type.

select transaction_type,max(amount)as highest_transaction_amount
from banking_transaction_data
group by transaction_type
order by highest_transaction_amount desc

--8.Find the monthly total transaction amount and transaction count.

select date_trunc('month',transaction_date)as transaction_month,
count(*)as transaction_count,
sum(amount)as total_transaction_amount
from banking_transaction_data
group by date_trunc('month',transaction_date)
order by transaction_month;

--9. What percentage of transactions were flagged as fraudulent for each branch.

select Branch,
count(*) as total_transactions,
sum(case when Fraud = 1 then 1 else 0 end) as fraud_transactions,
round(sum(case when Fraud = 1 then 1 else 0 end) * 100./ COUNT(*),2) AS fraud_rate_percentage
from banking_transaction_data
group by Branch
order by fraud_rate_percentage DESC;
--10.What is the average customer satisfaction score for each transaction channel.

select channel,
round(avg(customer_satisfaction),2) as satisfaction_score
from banking_transaction_data
group by channel
order by satisfaction_score desc;

--11.Rank customers within each branch based on their total transaction amount.

select 
Branch,
customer_id,
amount,
dense_rank()over(partition by branch
order by amount desc)as rnk
from banking_transaction_data 
order by branch,rnk
   
--12.Find the top 3 customers in each branch based on total transaction amount.

with ranker as (select 
Branch,
customer_id,
amount,
dense_rank()over(partition by branch
order by amount)as rnk
from banking_transaction_data 
order by branch,rnk asc )
select
Branch,Customer_ID,Amount,rnk
from ranker
where rnk <= 3
order by Branch,ranker;

--13.Calculate the month-over-month change in total transaction amount.

with monthly_transactions as (
select
year,
month,sum(Amount) AS total_amount
from banking_transaction_data
group by year, month),
monthly_analysis AS (
select
year,month,
total_amount,
lag(total_amount) over (
order by year,month) AS previous_month_amount
from monthly_transactions)
select
year,
month,total_amount,
previous_month_amount,
total_amount - previous_month_amount AS amount_change
from monthly_analysis
order by year, month;

--14.Find the second-highest transaction amount for each transaction type.

with ranked_transactions AS (
select Transaction_Type,Transaction_ID,
Customer_id,
Amount,
dense_rank()over(partition by Transaction_Type
order by Amount desc) AS transaction_rank
from banking_transaction_data)
select Transaction_Type,Transaction_ID,
Customer_id,Amount
FROM ranked_transactions
where transaction_rank = 2
order by transaction_Type;

--15.Identify branches with a fraud rate higher than the overall bank fraud rate.

with branch_fraud as (
select Branch,sum(case when Fraud = 1 then 1 else 0 end) * 100.0/ COUNT(*) AS branch_fraud_rate
from banking_transaction_data
group by Branch),
overall_fraud AS (
select sum(case when Fraud = 1 THEN 1 ELSE 0 END) * 100.0/ COUNT(*) AS overall_fraud_rate
from banking_transaction_data)
select Branch,ROUND(b.branch_fraud_rate, 2) AS branch_fraud_rate,
ROUND(o.overall_fraud_rate, 2) AS overall_fraud_rate
from  branch_fraud b
cross join overall_fraud o
where branch_fraud_rate > overall_fraud_rate
order by branch_fraud_rate DESC;
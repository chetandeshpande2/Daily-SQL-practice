-- Daily SQL Practice

-- 1. Retrieve all customers' full names and their city.

select coalesce("first_name") || ' ' || coalesce("last_name") as "full_name", city
from "customer" c
join "address" a
on c."zipcode_street_id" = a."zipcode_street_id";


-- 2. List all vehicles and their car make and model.

select "vin", "car_make", "car_model"
from "vehicle" v
join "car_type" c
on v."car_type_id" = c."car_type_id";


-- 3. Show the total number of claims in the claim table.

select count("claim_number") as total_claims
from claim;


-- 4. List all customers who live in New Jersey (state = 'NJ').

select "customer_number", coalesce("first_name") || ' ' || coalesce("last_name") as "full_name", a.state 
from "customer" c
join "address" a 
on c."zipcode_street_id" = a."zipcode_street_id"
where a."state" = 'New Jersey';


-- 5. Display all claim numbers along with their amount, sorted by the highest amount.

select "claim_number", "amount"
from claim 
order by "amount" DESC;


-- 6. Fetch the VIN, model year, and car make for all vehicles.

select "vin", "model_year", c."car_make"
from vehicle v
join car_type c
on v."car_type_id" = c."car_type_id";


-- 7. Get the customer numbers and policy numbers for policies that have expired.

select "customer_number", "policy_number", "expiration_date"
from "policy" p 
where "expiration_date" < current_date;


-- 8. Find the total number of customers in each state.

select count(c.customer_number) as "total_customers", a."state"
from "customer" c
join "address" a
on c."zipcode_street_id" = a."zipcode_street_id"
group by a."state"
order by a.state asc;


-- 9. Show the details of policies with a deductible above $500.

select "policy_number", "policy_limit", "expiration_date", "customer_number", "vin", "deductible"
from "policy" p 
where "deductible" > 500;


-- 10. Get all claims made on or after January 1, 2023.

select "claim_number", "claim_date"
from claim c 
where "claim_date" >= '1/1/23';


-- 11. List customers whose last name starts with "S".

select "last_name"
from customer
where "last_name" LIKE 'S%';


-- 12. Display the count of vehicles per car make.

select count("vin") as count_of_vehicles, c.car_make 
from vehicle v 
join car_type c
on v."car_type_id" = c."car_type_id"
group by c.car_make
order by "count_of_vehicles" desc;


-- 13. Join policy and vehicle to show policy number and vehicle make.

select "policy_number", c."car_make" as vehicle_make
from policy p
join vehicle v
on p."vin" = v."vin"
join car_type c
on v."car_type_id" = c."car_type_id";


-- 14. List all policies for a specific customer (e.g., customer_number = 'C123').

select c."customer_number", p."policy_number"
from customer c
join policy p
on c."customer_number" = p."customer_number";


-- 15. Get the names of customers who live on “Main Street”.

select coalesce("first_name") || ' ' || coalesce("last_name") as "full_name", a."street_address"
from customer c
join address a 
on c."zipcode_street_id" = a."zipcode_street_id"
where a."street_address" ilike '%Main Lane%';


--  Intermediate SQL Questions 

-- 1. Get the average claim amount per policy.

select "policy_number", AVG("amount") as "Average_CLaim"
from claim
group by "policy_number";


-- 2. List customers who have more than 1 policy.

select c.customer_number, count(p."policy_number") as number_of_policy
from customer c
join policy p
on c."customer_number" = p."customer_number"
group by c.customer_number
having count(p."policy_number") >= 1
order by count(p."policy_number") desc;


-- 3. Find policies that are linked to vehicles with model year after 2020.

select p.policy_number, v.vin, v.model_year
from policy p
join vehicle v
on p."vin" = v."vin"
where v.model_year > 2010;


-- 4. Show total deductible amount per customer.

select "customer_number", sum("deductible") as amount_per_customer
from "policy" p 
group by "customer_number"
order by amount_per_customer desc;


-- 5. Display customers who have made a claim of more than $2000.

select c."customer_number", cl."claim_number", cl."amount" as "Claim_Amount"
from customer c
join policy p
on c."customer_number" = p."customer_number"
join claim cl
on p."policy_number" = cl."policy_number"
where cl."amount" > 2000
order by cl."amount" desc;


-- 6. Find the most recent claim for each customer.

select c."customer_number", cl."claim_number", cl."claim_date", cl."amount"
from customer c
join policy p
on p."customer_number" = p."customer_number"
join claim cl
on p."policy_number" = cl."policy_number"
order by cl."claim_date" desc;


with ranked_claims as 
(select c."customer_number", cl."claim_number", cl."claim_date", cl."amount",
row_number() over(partition by c."customer_number" order by cl."claim_date" desc) as rank
from customer c
join policy p
on p."customer_number" = p."customer_number"
join claim cl
on p."policy_number" = cl."policy_number"
order by cl."claim_date" desc)

select "customer_number", "claim_number", "claim_date", "amount"
from ranked_claims
where rank = 1;


-- 7. Find the top 3 highest claim amounts per customer 

with ranked_claims as 
(select c."customer_number", cl."claim_number", cl."claim_date", cl."amount",
row_number() over(partition by c."customer_number" order by cl."claim_date" desc) as rank
from customer c
join policy p
on p."customer_number" = p."customer_number"
join claim cl
on p."policy_number" = cl."policy_number"
order by cl."claim_date" desc)

select "customer_number", "claim_number", "claim_date", "amount"
from ranked_claims
where rank <= 3
order by "customer_number", rank;


-- 8. List customers who have never made a claim (use NOT IN or LEFT JOIN).

select distinct c."customer_number", cl."amount"
from customer c
left join policy p
on c."customer_number" = p."customer_number"
left join claim cl
on p."policy_number" = cl."policy_number"
where claim_number is null;


-- 9. Retrieve car types (make and model) that are used in more than 5 policies.

select c."car_make", c."car_model", count(*) as "policy_count"
from policy p
join vehicle v
on p."vin" = v."vin"
join car_type c
on v."car_type_id" = c."car_type_id"
group by c."car_make", c."car_model" 
having count(*) > 5;


-- 10. Show policies with the highest policy limit per state.

with ranked_policy_limits as

(select p."policy_number", p."policy_limit", a."state",
row_number() over(partition by a."state" order by p."policy_limit" desc) as rank
from policy p
join customer c
on p."customer_number" = c."customer_number"
join address a
on c."zipcode_street_id" = a."zipcode_street_id")

select "policy_number", "policy_limit", "state"
from ranked_policy_limits
where rank = 1;


-- 11. Find policies that have no expiration date (NULL values).

select "policy_number", "expiration_date"
from policy
where "expiration_date" is null;



-- 12. Rank claims by amount within each policy.

select c."policy_number", c."claim_number", c."amount",
rank() over(partition by c."policy_number" order by c."amount" desc) as claim_amount
from claim c;


-- 13. List all addresses that have more than 2 customers registered.

select "street_address", a."zipcode_street_id", count(c."customer_number") as "customer_count"
from address a
join customer c
on a."zipcode_street_id" = c."zipcode_street_id"
group by "street_address", a."zipcode_street_id"
having count(c."customer_number") > 2;

SELECT 
  "street_address", 
  a."zipcode_street_id", 
  COUNT(c."customer_number") AS "customer_count"
FROM address a
JOIN customer c ON a."zipcode_street_id" = c."zipcode_street_id"
GROUP BY "street_address", a."zipcode_street_id"
ORDER BY customer_count DESC;


-- 14. Find the VINs of cars that have had more than 2 claims.

select v."vin", count(c."claim_number") as "no_of_claims"
from vehicle v 
join policy p
on v."vin" = p."vin"
join claim c
on p."policy_number" = c."policy_number" 
group by v."vin"
having count(c."claim_number") > 2;


-- 15. Get customer names with total claim amount > $10,000.

select coalesce(c."first_name", ' ') || ' ' || coalesce(c."last_name", ' ') as "full_name", SUM(cl."amount") as "total_claim_amount"
from customer c 
join policy p
on c."customer_number" = p."customer_number"
join claim cl
on cl."policy_number" = p."policy_number"
group by c."first_name", c."last_name"
having SUM(cl."amount") > 10000
order by "total_claim_amount" desc;


-- 16. Display customers whose policies expired in the last 6 months.

select C.customer_number, p."policy_number", p."expiration_date"
from customer c 
join policy p
on c."customer_number" = p."customer_number"
where p."expiration_date" < current_date and p
."expiration_date" >= current_date - interval '6 months';



SELECT 
  c."customer_number", 
  p."policy_number", 
  p."expiration_date"
FROM customer c 
JOIN policy p ON c."customer_number" = p."customer_number"
WHERE 
  p."expiration_date" <= (
    SELECT MAX("expiration_date") FROM policy
  )
  AND p."expiration_date" >= (
    SELECT MAX("expiration_date") FROM policy
  ) - INTERVAL '6 months';


-- PRACTICE QUESTIONS 2.0

-- A. JOINS & RELATIONSHIPS

-- 1. List all claims with their claim amount and the policy limit of the related policy.

select "claim_number", "amount", p."policy_limit"
from claim c
join policy p
on p."policy_number" = c."policy_number";


-- 2. Show each customer’s full name along with the VIN of their car(s).

select coalesce("first_name") || ' ' || coalesce ("last_name") as "full_name", v."vin"
from customer c 
join policy p
on c."customer_number" = p."customer_number"
join vehicle v
on p."vin" = v."vin";


-- 3. Retrieve each policy’s expiration date along with the customer’s city and state.

select "policy_number", "expiration_date", a."city", a."state"
from policy p
join customer c 
on p."customer_number" = c."customer_number"
join address a
on c."zipcode_street_id" = a.zipcode_street_id ;


-- 4. Show all vehicles with their car make/model and the customer who owns them.

select v."vin", c."car_make", c."car_model", p."customer_number"
from vehicle v 
join car_type c
on v."car_type_id" = c."car_type_id"
join policy p
on v."vin" = p."vin";


-- B. Aggregation & Grouping

-- 5. Count how many policies each customer has.

select count("policy_number"), c."customer_number"
from "policy" p 
join customer c
on p.customer_number = c.customer_number 
group by c."customer_number" ;


-- 6. Find the average claim amount per policy.

select avg(c."amount") as "Average_Amount", p."policy_number"
from claim c
join policy p
on c."policy_number" = p."policy_number"
group by p.policy_number ;


-- 7. For each car make, calculate the total number of claims.

select "car_make", count("claim_number") as "total number of claims"
from car_type ct 
join vehicle v 
on ct."car_type_id" = v."car_type_id"
join policy p
on v."vin" = p."vin"
join claim c
on c."policy_number" = p."policy_number"
group by "car_make" ;


-- 8. Get the total deductible amount grouped by state.

select sum(p."deductible") as "total_deductible", a."state"
from policy p
join customer c
on p."customer_number" = c."customer_number"
join address a
on c."zipcode_street_id" = a."zipcode_street_id"
group by a."state"
order by "total_deductible" DESC;


-- C. WINDOWS

-- 9. For each customer, assign a row number to their claims ordered by claim date.

select c.customer_number, cl.claim_number, cl.claim_date,
row_number() over(partition by c.customer_number order by cl.claim_date)
from customer c
join policy p
on c.customer_number = p.customer_number
join claim cl
on p.policy_number = cl.policy_number ;


-- 10. Show each claim along with the running total claim amount per customer.

select cl.claim_number, cl.claim_date, cl.amount,c.customer_number, 
SUM(cl.amount) over(partition by c.customer_number order by cl.claim_date, cl.claim_number rows between unbounded preceding and current row) as running_total
from customer c
join policy p
on c.customer_number = p.customer_number 
join claim cl
on p.policy_number = cl.policy_number 
order by c.customer_number, cl.claim_date, cl.amount;


-- 11. Find the latest claim date per customer using MAX() OVER (...).

select c.customer_number, cl.claim_date, cl.claim_number, cl.amount,
max(cl.claim_date) over(partition by c.customer_number) as latest_claim_date
from customer c
join policy p
on c.customer_number = p.customer_number
join claim cl
on cl.policy_number = p.policy_number
ORDER BY c.customer_number, cl.claim_date;


-- 12. Rank customers by their total claim amount (highest to lowest).

with totals as 
(select c.customer_number, sum(cl.amount) as total_amount
from customer c
join policy p
on c.customer_number = p.customer_number 
join claim cl
on cl.policy_number = p.policy_number
group by c.customer_number)
select customer_number, total_amount,
rank() over(order by total_amount desc) as Customer_Rank
from totals
order by total_amount desc;

-- 2nd Sept, 2025

-- 1. Write a query to find the total number of claims filed by each customer, along with their name.

select count(claim_number), cu.customer_number, coalesce("first_name") || ' ' || coalesce("last_name") as Full_Name
from claim c
join policy p 
on c.policy_number = p.policy_number
join customer cu
on p.customer_number = cu.customer_number 
group by cu.customer_number;


-- 2. Retrieve the count of claims grouped by their claim status (e.g., Approved, Pending, Rejected).

select count(claim_number), s.status as claim_status
from claim c
join status s
on c.status_id = s.status_id 
group by claim_status;


-- 3. Find all claims where the claim amount is greater than the policy_limit.

select claim_number, amount as claim_amount, p.policy_limit
from claim c
join policy p
on c.policy_number = p.policy_number 
where amount is not null 
and p.policy_limit is not null
and amount> p.policy_limit;


-- 4. Find the top 5 customers who have the highest total claim amounts. Display first_name, last_name, and total amount.

select c.customer_number as customer, sum(cl.amount) as total_claim_amount, c.first_name, c.last_name
from customer c
join policy p
on c.customer_number = p.customer_number 
join claim cl
on p.policy_number = cl.policy_number 
group by c.customer_number, c.first_name, c.last_name
order by total_claim_amount desc
limit 5;

-- 5. List all policies that have expired (expiration_date < CURRENT_DATE) but have no claims filed against them.

select p.policy_number, c.customer_number, p.expiration_date
from policy p
join customer c
on p.customer_number = c.customer_number xs
where p.policy_number is null
and p.expiration_date < CURRENT_DATE	;


-- Find the top 3 car models (make + model) that have the most claims associated with them.

select car_make, car_model, count(c.claim_number) as Most_Claims
from claim c
join policy p
on p.policy_number = c.policy_number 
join vehicle v
on p.vin = v.vin  
join car_type ct
on v.car_type_id = ct.car_type_id 
group by car_make, car_model
order by Most_Claims desc
limit 3;


-- 7. Calculate the average claim amount for customers grouped by their state.

select avg(c.amount), state
from claim c
join policy p
on c.policy_number = p.policy_number 
join customer cu
on p.customer_number = cu.customer_number
join address a
on cu.zipcode_street_id = a.zipcode_street_id 
group by a.state ;












8. Multiple Policies per Customer

Find all customers who hold more than 1 active policy.
👉 Tables: customer, policy

9. Claims per Year

Retrieve the total claim amount per year based on claim_date.
👉 Tables: claim

10. Join Challenge: Customer, Vehicle, Claim

Write a query that displays:

customer name

car make & model

policy number

claim amount
for all claims filed.












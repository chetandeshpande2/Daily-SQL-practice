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


-- 17. kjbscihbwihbco
















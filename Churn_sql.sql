SELECT * FROM churn.data;

-- 1. Retrieve top 10 distinct columns form ChurnModelling 
SELECT DISTINCT * FROM churn.data LIMIT 10;

-- 2. Retrieving Count the number of customers who have exited.
SELECT COUNT(*) AS ExitedCustomersCount FROM churn.data WHERE Exited = 1;

-- 3 Calculate the average balance by Geography.
SELECT Geography, AVG(Balance) AS AvgBalance FROM churn.data GROUP BY Geography;

-- 4. Find customers with a credit score above the average credit score.(subuery)
SELECT * FROM churn.data
WHERE CreditScore > (SELECT AVG(CreditScore) FROM churn.data);

-- 5. Retrieve customers who are active members and have more than two products.
-- (Conditional Retrieval)

SELECT * FROM churn.data
WHERE IsActiveMember = 1 AND NumOfProducts > 2;

-- 6. Determine the average balance and estimated salary for different age groups.
SELECT 
    CASE
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age >= 30 AND Age < 40 THEN '30-39'
        WHEN Age >= 40 AND Age < 50 THEN '40-49'
        ELSE '50 and over'
    END AS AgeGroup,
    AVG(Balance) AS AvgBalance,
    AVG(EstimatedSalary) AS AvgSalary
FROM churn.data
GROUP BY AgeGroup
ORDER BY AgeGroup;

-- 7. Calculate the churn rate (percentage of customers who have exited) and analyze churn behavior based on various factors.
SELECT
    Geography,
    AVG(Exited) AS ChurnRate,
    AVG(CreditScore) AS AvgCreditScore,
    AVG(Balance) AS AvgBalance
FROM churn.data
GROUP BY Geography
ORDER BY ChurnRate DESC;

-- 8. Implement dynamic segmentation based on real-time updates in customer behavior, such as changes in balance or product ownership.
-- Example using window functions for dynamic segmentation
SELECT
    CustomerId,
    Balance,
    NumOfProducts,
    ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY Balance DESC) AS Segment
FROM churn.data;

-- 9. Calculate the CLV for each customer based on their tenure, average balance, and estimated salary.
SELECT
    CustomerId,
    SUM(Balance) AS TotalBalance,
    AVG(EstimatedSalary) AS AvgSalary,
    Tenure,
    (SUM(Balance) / Tenure) * AVG(EstimatedSalary) AS CLV
FROM churn.data
GROUP BY CustomerId, Tenure
ORDER BY CLV DESC;
	
-- 10. Identify opportunities for cross-selling and up-selling by analyzing product ownership and balance distribution.
SELECT
    NumOfProducts,
    AVG(Balance) AS AvgBalance,
    COUNT(*) AS CustomerCount
FROM churn.data
GROUP BY NumOfProducts
ORDER BY NumOfProducts;

-- 11. Check if Customer has Credit Card
-- Create a UDF to convert the HasCrCard column (which is likely a bit or boolean) into a more readable format.
Use db churn
	DELIMITER //
	CREATE FUNCTION HasCreditCard(hasCrCard BIT)
	RETURNS VARCHAR(3)
    DETERMINISTIC
	BEGIN
		DECLARE result VARCHAR(3);
		SET result = CASE WHEN hasCrCard = 1 THEN 'Yes' ELSE 'No' END;
		RETURN result;
	END
	//

	DELIMITER ;
	SELECT CustomerId, Surname, HasCrCard, HasCreditCard(HasCrCard) AS HasCreditCard
	FROM churn.data;

-- 12. Explore Customer Demographics and Churn
-- Objective: Investigate the relationship between customer demographics (gender, age) and churn.
WITH DemographicsChurn AS (
    SELECT 
        Gender,
        Age,
        AVG(Exited) * 100 AS ChurnRatePercentage
    FROM churn.data
    GROUP BY Gender, Age
)

SELECT Gender, Age, ChurnRatePercentage
FROM DemographicsChurn
ORDER BY Gender, Age;

-- 13. Determine Customer Tenure and Estimated Salary Trends
-- Objective: Analyze the relationship between customer tenure and estimated salary.
WITH TenureSalaryAnalysis AS (
    SELECT 
        Tenure,
        AVG(EstimatedSalary) AS AvgEstimatedSalary
    FROM churn.data
    GROUP BY Tenure
)

SELECT Tenure, AvgEstimatedSalary
FROM TenureSalaryAnalysis
ORDER BY Tenure;

-- 14. Analyze Customer Age Distribution
-- Objective: Calculate the count of customers in different age groups.
WITH AgeDistribution AS (
    SELECT 
        CASE 
            WHEN Age < 30 THEN 'Under 30'
            WHEN Age >= 30 AND Age < 40 THEN '30-39'
            WHEN Age >= 40 AND Age < 50 THEN '40-49'
            ELSE '50 and over'
        END AS AgeGroup,
        COUNT(*) AS CustomerCount
    FROM churn.data
    GROUP BY AgeGroup
)

SELECT AgeGroup, CustomerCount
FROM AgeDistribution
ORDER BY AgeGroup;

-- 15. How many customers having a credit score between 600 and 700 are male and female? 
-- And also tell what is the average salary of male customers and female customers in that Credit Score bracket?

select Gender,count(CustomerId) as No_of_customers,round(avg(EstimatedSalary),2) as Average_Salary from churn.data
where CreditScore between 600 and 700
group by Gender;

-- 16. How many male and female customers have been churned out in different Countries in different age brackets?
# age is between 18 and 30 .....Young
# age is bweteen 30 to 45.....Adults
# age is between 45 to 60.....MiddlE_Aged
#>60..........................Senior_Citizens
with ABC as
(select *, 
case when Age>=18 and Age<30 then "Young"
     when Age>=30 and Age<45 then "Adult"
     when Age>=45 and Age<60 then "Middle_Aged"
     else "Senior_Citizen"
     end as Age_bracket
     from churn.data)
select Gender,Geography,Exited,count(CustomerID) as Churned_customers from ABC
group by Gender,Geography,Exited
having Exited = 1
order by Gender, Geography;

SELECT
    Geography,
    COUNT(*) AS ChurnedCustomersCount,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS ChurnedCustomersPercentage
FROM
    churn.data
WHERE
    Exited = 1
GROUP BY
    Geography;
    
    SELECT
    COUNT(*) AS TotalCustomers,
    SUM(Exited) AS ChurnedCustomers,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 2) AS ChurnRate
FROM
    churn.data;


SELECT
    AVG(Age) AS AvgAgeChurnedCustomers
FROM
    churn.data
WHERE
    Exited = 1;
    
    SELECT
    NumOfProducts,
    COUNT(*) AS NumCustomers
FROM
    churn.data
GROUP BY
    NumOfProducts
ORDER BY
    NumOfProducts;
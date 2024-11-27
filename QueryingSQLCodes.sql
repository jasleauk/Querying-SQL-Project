-- Filter Products by Color and Price Range, Sorted by Standard Cost
SELECT ([Name]),[Color],[ListPrice],[StandardCost] AS Price
FROM [Production].[Product]
WHERE [Color] IS NOT NULL
AND [Color] NOT IN ('Silver', 'Black', 'White')
AND [StandardCost] BETWEEN 75 AND 750
ORDER BY [StandardCost] DESC;



-- Filter Employees by Gender, Birth Date, and Hire Date
SELECT *
FROM [HumanResources].[Employee]
WHERE ([Gender] = 'M' AND [BirthDate] BETWEEN '1962-01-01' AND '1970-12-31' AND [HireDate] > '2001-01-01') 
OR ([Gender] = 'F' AND [BirthDate] BETWEEN '1972-01-01' AND '1975-12-31' AND [HireDate] BETWEEN '2001-01-01' AND '2002-12-31');





-- Filter Products with Product Number Starting with 'BK', Sorted by Price
SELECT TOP 10 
[ProductID],([Name]),[Color]
FROM [Production].[Product]
WHERE [ProductNumber] LIKE 'BK%'
ORDER BY [ListPrice] DESC;





-- Concatenate First and Last Name, and Calculate Full Name Length
SELECT [FirstName],[LastName],
CONCAT([FirstName], ' ', [LastName]) AS full_name,
LEN(CONCAT([FirstName], ' ', [LastName])) AS full_name_length
FROM [Person].[Person] 
WHERE LEFT([FirstName], 1) = LEFT([LastName], 1);






-- Join Product Subcategories and Products, Filter by Days to Manufacture
SELECT PPC.[ProductSubcategoryID],
PPC.[Name],
PP.[DaysToManufacture]
FROM
[Production].[ProductSubcategory] AS PPC
INNER JOIN
[Production].[Product] AS PP
ON PP.[ProductSubcategoryID] = PPC.[ProductSubcategoryID]
WHERE PP.[DaysToManufacture] >= 3;






-- Classify Products by Price Range for Specific Colors
SELECT [ProductID],[Name],[Color],[ListPrice],
CASE
    WHEN [ListPrice] < 200 THEN 'Low Value'
    WHEN [ListPrice] BETWEEN 201 AND 750 THEN 'Mid Value'
    WHEN [ListPrice] BETWEEN 751 AND 1250 THEN 'Mid to High Value'
    ELSE 'Higher Value'
END AS price_segment
FROM [Production].[Product]
WHERE [Color] IN ('Black', 'Silver', 'Red');





-- Count Distinct Job Titles in Employee Table
SELECT 
    COUNT(DISTINCT [JobTitle]) AS distinct_job_titles
FROM [HumanResources].[Employee];

-- Calculate Age at Hire for Employees
SELECT 
    BusinessEntityID,
    LoginID,
    BirthDate,
    HireDate,
    DATEDIFF(YEAR, BirthDate, HireDate) AS age_at_hire
FROM 
    HumanResources.Employee;






-- Count Employees Eligible for Long Service Award
SELECT 
    AwardStatus,
    COUNT(*) AS NumberOfEmployees
FROM (
    SELECT 
    [NationalIDNumber],[JobTitle],[HireDate],

    CASE
        WHEN DATEDIFF(YEAR,[HireDate],GETDATE()) > 15 THEN 'Eligible for Long Service Award'
        ELSE 'Not Eligible'
    END AS AwardStatus

    FROM 
    HumanResources.Employee
) AS SubQuery
GROUP BY 
    AwardStatus;








-- List Employees with Long Service Award Eligibility Status
SELECT 
    [NationalIDNumber],[JobTitle],[HireDate],

    CASE
        WHEN DATEDIFF(YEAR,[HireDate],GETDATE()) > 15 THEN 'Eligible for Long Service Award'
        ELSE 'Not Eligible'
    END AS AwardStatus

FROM 
    HumanResources.Employee;







-- Calculate Retirement Date and Years Until Retirement
SELECT [NationalIDNumber],[JobTitle],[HireDate],[BirthDate],
DATEADD(YEAR, 65, BirthDate) AS RetirementDate,
DATEDIFF(YEAR, GETDATE(), DATEADD(YEAR, 65, BirthDate)) AS YearsUntilRetirement,
CASE
WHEN DATEDIFF(YEAR, GETDATE(), DATEADD(YEAR, 65, BirthDate)) < 0 THEN 0
    ELSE DATEDIFF(YEAR, GETDATE(), DATEADD(YEAR, 65, BirthDate))
    END AS YearsUntilRetirement
FROM 
    HumanResources.Employee;











-- Adjust Prices and Commissions Based on Product Color
SELECT
    [ProductID],
    [Color],
    [ListPrice],
    CASE
        WHEN [Color] = 'White' THEN ListPrice * 1.08
        WHEN [Color] = 'Yellow' THEN ListPrice * 0.925
        WHEN [Color] = 'Black' THEN ListPrice * 1.172
        WHEN [Color] IN ('Multi', 'Silver', 'Silver/Black', 'Blue') THEN POWER(ListPrice, 0.5) * 2
        ELSE [ListPrice]
    END AS [NewPrice],
    CASE
        WHEN [Color] = 'White' THEN (ListPrice * 1.08) * 0.375
        WHEN [Color] = 'Yellow' THEN (ListPrice * 0.925) * 0.375
        WHEN [Color] = 'Black' THEN (ListPrice * 1.172) * 0.375
        WHEN [Color] IN ('Multi', 'Silver', 'Silver/Black', 'Blue') THEN (POWER(ListPrice, 0.5) * 2) * 0.375
        ELSE ListPrice * 0.375
    END AS [Commission]
FROM
    [Production].[Product];









-- Calculate Sales Order and Customer Information with Commission
SELECT
    soh.[SalesOrderID] AS OrderNumber,
    soh.[OrderDate] AS OrderDate,
    soh.[TotalDue] AS AmountOfOrder,
    c.[CustomerID] AS CustomerID,
    p.[FirstName] AS CustomerFirstName,
    p.[LastName] AS CustomerLastName,
    sp.[FirstName] AS SalesPersonFirstName,
    sp.[LastName] AS SalesPersonLastName,
    soh.[TotalDue] * 0.05 AS SalesPersonCommission -- Assuming commission is 5% of the order amount
FROM
    Sales.SalesOrderHeader AS soh
JOIN
    Sales.Customer AS c ON soh.CustomerID = c.CustomerID
JOIN
    Person.Person AS p ON c.PersonID = p.BusinessEntityID
LEFT JOIN
    Sales.vSalesPerson AS sp ON soh.SalesPersonID = sp.BusinessEntityID;











-- Get Top 5 Products by Price for Each Color
WITH RankedProducts AS (
    SELECT
        ProductID,
        [Name] AS ProductName,
        Color,
        ListPrice,
        ROW_NUMBER() OVER (PARTITION BY Color ORDER BY ListPrice DESC) AS RankWithinColor
    FROM
        [Production].[Product]
    WHERE
        ListPrice IS NOT NULL and Color is NOT NULL
)
SELECT
    ProductID,
    ProductName,
    Color,
    ListPrice
FROM
    RankedProducts
WHERE
    RankWithinColor <= 5
ORDER BY
    Color,
    RankWithinColor;

-- Create a View for Top 5 Products by Price for Each Color
CREATE VIEW Top5ProductsPerColor AS
WITH RankedProducts AS (
    SELECT
        ProductID,
        [Name] AS ProductName,
        Color,
        ListPrice,
        ROW_NUMBER() OVER (PARTITION BY Color ORDER BY ListPrice DESC) AS RankWithinColor
    FROM
        [Production].[Product]
    WHERE
        ListPrice IS NOT NULL and Color is NOT NULL
)
SELECT
    ProductID,
    ProductName,
    Color,
    ListPrice
FROM
    RankedProducts
WHERE
    RankWithinColor <= 5
ORDER BY
    Color,
    RankWithinColor;
GO

SELECT *
FROM [dbo].[Top5ProductsPerColor];

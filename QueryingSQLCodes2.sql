-- Concatenate First and Last Name, Calculate Full Name Length, and Match Email Address Prefix
SELECT [FirstName], [LastName],
CONCAT([FirstName], ' ', [LastName]) AS [FullName],
LEN(CONCAT([FirstName], [LastName])) AS [FullNameLength]
FROM [Person].[Person] p
JOIN [Person].[EmailAddress] e ON p.[BusinessEntityID] = e.[BusinessEntityID]
WHERE LEFT([p].[LastName], 4) = LEFT([e].[EmailAddress], 4)
  AND LEFT([p].[FirstName], 1) = LEFT([p].[LastName], 1);

-- Calculate Average Manufacturing Days by Product Subcategory
SELECT PPC.[ProductSubcategoryID],
PPC.[Name],
AVG(PP.[DaysToManufacture]) AS [Average Manu. Days]
FROM [Production].[ProductSubcategory] AS PPC
INNER JOIN [Production].[Product] AS PP
ON PP.[ProductSubcategoryID] = PPC.[ProductSubcategoryID]
GROUP BY PPC.[ProductSubcategoryID], PPC.[Name]
HAVING AVG(PP.[DaysToManufacture]) >= 3;

-- Count Employees Eligible for Long Service Award Based on Years of Service
SELECT 
    [AwardStatus],
    COUNT(*) AS [NumberOfEmployees]
FROM (
    SELECT 
        [NationalIDNumber],
        [JobTitle],
        [HireDate],
        CASE
            WHEN DATEDIFF(YEAR, [HireDate], GETDATE()) + 5 >= 20 THEN 'Eligible for Long Service Award'
            ELSE 'Not Eligible'
        END AS [AwardStatus]
    FROM 
        [HumanResources].[Employee]
) AS [SubQuery]
GROUP BY 
    [AwardStatus];

-- Retrieve Sales Order Details with Commission Based on Salesperson Percentage
SELECT
    soh.[SalesOrderID] AS [OrderNumber],
    soh.[OrderDate] AS [OrderDate],
    soh.[SubTotal] AS [AmountOfOrder],
    soh.[OnlineOrderFlag] AS [OnlineOrderFlag],
    p.[FirstName] AS [CustomerFirstName],
    p.[LastName] AS [CustomerLastName],
    soh.[SubTotal] * COALESCE(sp.[CommissionPct], 0) AS [SalesPersonCommission]
FROM
    [Sales].[SalesOrderHeader] AS soh
JOIN
    [Sales].[Customer] AS c ON soh.[CustomerID] = c.[CustomerID]
JOIN
    [Person].[Person] AS p ON c.[PersonID] = p.[BusinessEntityID]
LEFT JOIN
    [Sales].[SalesPerson] AS sp ON soh.[SalesPersonID] = sp.[BusinessEntityID];

-- Create a View to Get Top Products by Color Based on List Price
CREATE VIEW dbo.TopProductsByColor AS
WITH RankedProducts AS (
    SELECT
        ProductID,
        [Name] AS ProductName,
        Color,
        ListPrice,
        DENSE_RANK() OVER (PARTITION BY Color ORDER BY ListPrice DESC) AS RankWithinColor
    FROM
        [Production].[Product]
    WHERE
        ListPrice IS NOT NULL
        AND Color IS NOT NULL
)
SELECT
    ProductID,
    ProductName,
    Color,
    ListPrice,
    RankWithinColor
FROM
    RankedProducts;

-- Retrieve Top 5 Products by Color Using the Created View
SELECT
    ProductID,
    ProductName,
    Color,
    ListPrice
FROM
    dbo.TopProductsByColor
WHERE
    RankWithinColor <= 5
ORDER BY
    Color,
    RankWithinColor;

-- Check the Contents of the Created View for Top Products by Color
SELECT TOP 10 *
FROM dbo.TopProductsByColor;

-- Creating Table if not Exists
USE envdev;

-- Table Customers
Create Table if Not Exists Customers (
    Customer_Id int Not Null,
    Customer_Name varchar(255) Not Null,
    Product_Name varchar(255) Not Null,
    Product_Volume varchar(255) Not Null,
    Value_UnitPrice decimal(10,2) Not Null,
    Value_Total decimal(10,2) Not Null,
    Primary Key (Customer_Id)
);

-- Introducing the Table Creation to one procedure
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateTable`()
BEGIN
	Create Table if Not ExistsMSQ Customers (
		Customer_Id int Not Null,
		Customer_Name varchar(255) Not Null,
		Product_Name varchar(255) Not Null,
		Product_Volume varchar(255) Not Null,
		Value_UnitPrice decimal(10,2) Not Null,
		Value_Total decimal(10,2) Not Null,
		Primary Key (Customer_Id)
	);
END

-- Test Procedure
CALL CreateTable();

-- Check Folder Permission to upload file *Config File: "C:\ProgramData\MySQL\MySQL Server 8.0\my.ini"
SELECT @@secure_file_priv;

-- Upload CSV File to Table (Enable file my.ini Configuration to make effect in csv import)
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Customers.csv"
INTO TABLE customers
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS;
-- Check Table Created
SELECT * FROM customers;

-- Checking the total Value in customers table
SELECT SUM(Value_Total) as Total_Table
FROM customers;

-- Checking the total value in a calculated table
SELECT SUM(Total_Value) as Total_Sum
FROM (
    SELECT SUM((Product_Volume / 100) * (Value_UnitPrice * 200)) as Total_Value
    FROM customers
    GROUP BY Customer_Id
) subquery;

-- Creating the View of Calculated Table
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `calculatedcostumers` AS
    SELECT 
        `customers`.`Customer_Id` AS `Customer_ID`,
        `customers`.`Customer_Name` AS `Customer_Name`,
        `customers`.`Product_Name` AS `Product_Name`,
        `customers`.`Product_Volume` AS `Product_Volume`,
        `customers`.`Value_UnitPrice` AS `Value_UnitPrice`,
        ((`customers`.`Product_Volume` / 100) * (`customers`.`Value_UnitPrice` * 200)) AS `TotalCalculated`
    FROM
        `customers`
        
-- Generate the View calculatedcostumers
SELECT * FROM calculatedcostumers

-- Checking The Difference Between Customers Table and Calculated Table using difference view
CREATE
	ALGORITHM = UNDEFINED DEFINER = `root`@`localhost`
	SQL SECURITY DEFINER 
	VIEW `difference` AS

SELECT 'Valor CSV' AS `Source`,
       SUM(`customers`.`Value_Total`) AS `Total`
FROM `customers`

UNION ALL

SELECT 'Valor Calculado' AS `Source`,
       SUM(`subquery`.`Total_Value`) AS `Total`
FROM
  (SELECT `customers`.`Customer_Id` AS `Customer_Id`,
          SUM(((`customers`.`Product_Volume` / 100) * (`customers`.`Value_UnitPrice` * 200))) AS `Total_Value`
   FROM `customers`
   GROUP BY `customers`.`Customer_Id`) `subquery`

-- Creating View of Difference
select * from difference

-- Indentify The Row have Difference
SELECT customers.Customer_Id,
       customers.Customer_Name,
       customers.Product_Name,
       customers.Product_Volume,
       customers.Value_UnitPrice,
       customers.Value_Total
FROM customers
LEFT JOIN calculatedcostumers ON customers.Customer_Id = calculatedcostumers.Customer_ID
WHERE calculatedcostumers.Customer_ID IS NULL
  OR customers.Value_Total <> calculatedcostumers.TotalCalculated;


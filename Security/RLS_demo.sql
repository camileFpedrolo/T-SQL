CREATE USER Manager WITHOUT LOGIN;
CREATE USER SalesRep1 WITHOUT LOGIN;
CREATE USER SalesRep2 WITHOUT LOGIN;
GO

CREATE SCHEMA Sales
GO
CREATE TABLE Sales.Orders
    (
    OrderID int,
    SalesRep nvarchar(50),
    Product nvarchar(50),
    Quantity smallint
    );

INSERT INTO Sales.Orders  VALUES (1, 'SalesRep1', 'Valve', 5);
INSERT INTO Sales.Orders  VALUES (2, 'SalesRep1', 'Wheel', 2);
INSERT INTO Sales.Orders  VALUES (3, 'SalesRep1', 'Valve', 4);
INSERT INTO Sales.Orders  VALUES (4, 'SalesRep2', 'Bracket', 2);
INSERT INTO Sales.Orders  VALUES (5, 'SalesRep2', 'Wheel', 5);
INSERT INTO Sales.Orders  VALUES (6, 'SalesRep2', 'Seat', 5);
-- View the 6 rows in the table
SELECT * FROM Sales.Orders;

GRANT SELECT ON Sales.Orders TO Manager;
GRANT SELECT ON Sales.Orders TO SalesRep1;
GRANT SELECT ON Sales.Orders TO SalesRep2;
GO

CREATE SCHEMA Security;
GO

CREATE FUNCTION Security.tvf_securitypredicate(@SalesRep AS nvarchar(50))
    RETURNS TABLE
WITH SCHEMABINDING
AS
    RETURN SELECT 1 AS tvf_securitypredicate_result
WHERE @SalesRep = USER_NAME() OR USER_NAME() = 'Manager';
GO

CREATE SECURITY POLICY SalesFilter
ADD FILTER PREDICATE Security.tvf_securitypredicate(SalesRep)
ON Sales.Orders
WITH (STATE = ON);
GO

GRANT SELECT ON Security.tvf_securitypredicate TO Manager;
GRANT SELECT ON Security.tvf_securitypredicate TO SalesRep1;
GRANT SELECT ON Security.tvf_securitypredicate TO SalesRep2;

EXECUTE AS USER = 'SalesRep1';
SELECT * FROM Sales.Orders;
REVERT;

CREATE FUNCTION Security.tvf_securitypredicate2(@SalesRep AS nvarchar(50))
    RETURNS TABLE
WITH SCHEMABINDING
AS
    RETURN SELECT 1 AS tvf_securitypredicate_result
WHERE USER_NAME() = 'Manager';
GO

CREATE SECURITY POLICY SalesFilter2
ADD FILTER PREDICATE Security.tvf_securitypredicate2(SalesRep)
ON Sales.Orders
WITH (STATE = ON);
GO

-- UMA TABELA SÓ PODE SER "REGIDA" POR UMA POLICY POR VEZ, OU SEJA, ANTES DE APLICAR UMA NOVA POLICY, PRECISA DESATIVARA A ANTERIOR
ALTER SECURITY POLICY SalesFilter
WITH (STATE = OFF);

ALTER SECURITY POLICY SalesFilter2
WITH (STATE = ON);


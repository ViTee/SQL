DROP TABLE IF EXISTS  CUSTOMER
CREATE TABLE CUSTOMER
(
ID INT PRIMARY KEY,
CUSTOMER_NAME VARCHAR(255),
CITY_ID INT,
)

DROP TABLE IF EXISTS USER_ACCOUNT
CREATE TABLE USER_ACCOUNT
(
ID INT PRIMARY KEY,
FIRST_NAME VARCHAR(64),
LAST_NAME VARCHAR(64),
)

DROP TABLE IF EXISTS CONTACT
CREATE TABLE CONTACT
(
ID INT PRIMARY KEY,
USER_ACCOUNT_ID INT,
CUSTOMER_ID INT,
)

INSERT INTO CUSTOMER (ID,CUSTOMER_NAME,CITY_ID)
VALUES
(1,'DRO WIE',1),
(2,'CO ST',4),
(3,'KOS',3),
(4,'NEU KOS',1),
(5,'BIO KOS',2),
(6,'K-WI',1),
(7,'NAT COS',2),
(8,'KOS PLU',2),
(9,'NEW LC',4)

INSERT INTO USER_ACCOUNT (ID,FIRST_NAME,LAST_NAME)
VALUES
(1,'JURGEN','KLOPP'),
(2,'JOSE','MOURINHO'),
(3,'JOSEP','GUARDIOLA'),
(4,'ALEX','FERGUSON')

INSERT INTO CONTACT (ID,USER_ACCOUNT_ID,CUSTOMER_ID)
VALUES
(1,4,7),
(2,1,2),
(3,2,9),
(4,3,2),
(5,1,6),
(6,4,3),
(7,3,5),
(8,4,4),
(9,3,8),
(10,4,7),
(11,3,9),
(12,3,5),
(13,4,7),
(14,4,3)

--Find all pairs of customers and agents(users) who have been in contact more than once

SELECT US.ID,US.FIRST_NAME,US.LAST_NAME,CU.ID,CU.CUSTOMER_NAME,COUNT(CU.ID)
FROM CUSTOMER CU,USER_ACCOUNT US,CONTACT CO
WHERE CU.ID=CO.CUSTOMER_ID AND US.ID=CO.USER_ACCOUNT_ID
GROUP BY US.ID,US.FIRST_NAME,US.LAST_NAME,CU.ID,CU.CUSTOMER_NAME
HAVING COUNT(CU.ID)>1

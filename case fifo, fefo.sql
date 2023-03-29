--THAY DOI KIEU DU LIEU THNAH DATETIME
--ALTER TABLE INVENTORY
--ALTER COLUMN good_receipt_time datetime
--ALTER TABLE INVENTORY
--ALTER COLUMN expiry_date_time datetime

--TABLE PICKING QUANTITY
WITH PQ1 AS 
(SELECT INV.*, ORD.ORDER_QTY,
CASE 
   WHEN ORD.[Exporting_Rule ] = 'FIFO'
   THEN SUM(Stock_qty) OVER(PARTITION BY INV.Item_code ORDER BY INV.good_receipt_time, LEFT(RIGHT(INV.Location, 2),1) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
   WHEN ORD.[Exporting_Rule ] = 'FEFO'
   THEN SUM(Stock_qty) OVER(PARTITION BY INV.Item_code ORDER BY INV.EXPIRY_DATE_TIME, LEFT(RIGHT(INV.Location, 2),1) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
   WHEN ORD.[Exporting_Rule ] = 'LIFO'
   THEN SUM(Stock_qty) OVER(PARTITION BY INV.Item_code ORDER BY INV.good_receipt_time DESC, LEFT(RIGHT(INV.Location, 2),1) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
   WHEN ORD.[Exporting_Rule ] LIKE 'EXPIRY%' AND DATEDIFF(DAY, INV.expiry_date_time, CONVERT(DATETIME, RIGHT(ORD.[Exporting_Rule ], 18))) = 0
   THEN SUM(Stock_qty) OVER(PARTITION BY INV.Item_code, INV.EXPIRY_DATE_TIME ORDER BY LEFT(RIGHT(INV.Location, 2),1) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
   ELSE 0
END AS INCRE_QTY
FROM inventory INV INNER JOIN orders ORD
ON INV.item_code = ORD.Item_code),
PQ2 AS (SELECT *, LAG (INCRE_QTY) OVER (PARTITION BY Item_code ORDER BY INCRE_QTY) AS LAG_INCRE
FROM PQ1)   
SELECT ITEM_CODE, LOCATION, GOOD_RECEIPT_TIME, EXPIRY_DATE_TIME AS EXP_DATE_TIME,
case 
  when Incre_qty > Order_qty and LAG_INCRE IS NULL then Order_qty
  when Incre_qty between 1 and Order_qty then Stock_qty 
  when Incre_qty > Order_qty AND LAG_INCRE < Order_qty THEN Order_qty - LAG_INCRE
  else 0 
end as PICKING_QUANTITY
FROM PQ2;

--TABLE REMAIN QUANTITY
WITH RQ1 AS 
(SELECT INV.*, ORD.ORDER_QTY,
CASE 
   WHEN ORD.[Exporting_Rule ] = 'FIFO'
   THEN SUM(Stock_qty) OVER(PARTITION BY INV.Item_code ORDER BY INV.good_receipt_time, LEFT(RIGHT(INV.Location, 2),1) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
   WHEN ORD.[Exporting_Rule ] = 'FEFO'
   THEN SUM(Stock_qty) OVER(PARTITION BY INV.Item_code ORDER BY INV.EXPIRY_DATE_TIME, LEFT(RIGHT(INV.Location, 2),1) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
   WHEN ORD.[Exporting_Rule ] = 'LIFO'
   THEN SUM(Stock_qty) OVER(PARTITION BY INV.Item_code ORDER BY INV.good_receipt_time DESC, LEFT(RIGHT(INV.Location, 2),1) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
   WHEN ORD.[Exporting_Rule ] LIKE 'EXPIRY%' AND DATEDIFF(DAY, INV.expiry_date_time, CONVERT(DATETIME, RIGHT(ORD.[Exporting_Rule ], 18))) = 0
   THEN SUM(Stock_qty) OVER(PARTITION BY INV.Item_code, INV.EXPIRY_DATE_TIME ORDER BY LEFT(RIGHT(INV.Location, 2),1) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
   ELSE 0
END AS INCRE_QTY
FROM inventory INV INNER JOIN orders ORD
ON INV.item_code = ORD.Item_code),
RQ2 AS (SELECT *, LAG (INCRE_QTY) OVER (PARTITION BY Item_code ORDER BY INCRE_QTY) AS LAG_INCRE
FROM RQ1)   
SELECT ITEM_CODE, LOCATION, GOOD_RECEIPT_TIME, EXPIRY_DATE_TIME AS EXP_DATE_TIME,
case 
  when Incre_qty > Order_qty and LAG_INCRE IS NULL then Stock_qty - Order_qty
  when Incre_qty between 1 and Order_qty then 0
  when Incre_qty > Order_qty AND LAG_INCRE < Order_qty THEN Incre_qty - Order_qty
  else Stock_qty 
end as REMAIN_QUANTITY
FROM RQ2;

--KET HOP CA 2 TABLE TREN
WITH PRQ1 AS 
(SELECT INV.*, ORD.ORDER_QTY,
CASE 
   WHEN ORD.[Exporting_Rule ] = 'FIFO'
   THEN SUM(Stock_qty) OVER(PARTITION BY INV.Item_code ORDER BY INV.good_receipt_time, LEFT(RIGHT(INV.Location, 2),1) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
   WHEN ORD.[Exporting_Rule ] = 'FEFO'
   THEN SUM(Stock_qty) OVER(PARTITION BY INV.Item_code ORDER BY INV.EXPIRY_DATE_TIME, LEFT(RIGHT(INV.Location, 2),1) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
   WHEN ORD.[Exporting_Rule ] = 'LIFO'
   THEN SUM(Stock_qty) OVER(PARTITION BY INV.Item_code ORDER BY INV.good_receipt_time DESC, LEFT(RIGHT(INV.Location, 2),1) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
   WHEN ORD.[Exporting_Rule ] LIKE 'EXPIRY%' AND DATEDIFF(DAY, INV.expiry_date_time, CONVERT(DATETIME, RIGHT(ORD.[Exporting_Rule ], 18))) = 0
   THEN SUM(Stock_qty) OVER(PARTITION BY INV.Item_code, INV.EXPIRY_DATE_TIME ORDER BY LEFT(RIGHT(INV.Location, 2),1) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
   ELSE 0
END AS INCRE_QTY
FROM inventory INV INNER JOIN orders ORD
ON INV.item_code = ORD.Item_code),
PRQ2 AS (SELECT *, LAG (INCRE_QTY) OVER (PARTITION BY Item_code ORDER BY INCRE_QTY) AS LAG_INCRE
FROM PRQ1)   
SELECT ITEM_CODE, LOCATION, GOOD_RECEIPT_TIME, EXPIRY_DATE_TIME AS EXP_DATE_TIME, ORDER_QTY, STOCK_QTY,
case 
  when Incre_qty > Order_qty and LAG_INCRE IS NULL then Order_qty
  when Incre_qty between 1 and Order_qty then Stock_qty 
  when Incre_qty > Order_qty AND LAG_INCRE < Order_qty THEN Order_qty - LAG_INCRE
  else 0 
end as PICKING_QUANTITY,
case 
  when Incre_qty > Order_qty and LAG_INCRE IS NULL then Stock_qty - Order_qty
  when Incre_qty between 1 and Order_qty then 0
  when Incre_qty > Order_qty AND LAG_INCRE < Order_qty THEN Incre_qty - Order_qty
  else Stock_qty 
end as REMAIN_QUANTITY
FROM PRQ2;
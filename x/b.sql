INSERT INTO sns_snap_daily_sales(
  brand_id,
  sns_snap_id,
  direct_sales,
  indirect_sales,
  direct_sales_count,
  indirect_sales_count,
  direct_product_count,
  indirect_product_count,
  pv,
  date
)
SELECT cv.brand_id,
       cv.sns_snap_id              AS sns_snap_id,
       cv.direct_sales             AS direct_sales,
       cv.indirect_sales           AS indirect_sales,
       cv.direct_sales_count       AS direct_sales_count,
       cv.indirect_sales_count     AS indirect_sales_count,
       cv.direct_product_count     AS direct_product_count,
       cv.indirect_product_count   AS indirect_product_count,
       IF(pv.count IS NULL, 0, pv.count) AS pv,
       @date                       AS date
FROM
  -- cvにpvをLEFT JOIN
  (SELECT cv.brand_id,
  s.id                                                               AS sns_snap_id,
  SUM(IF(conversion_type IN (1, 2), (cv.price * cv.count), 0))       AS direct_sales,
  SUM(IF(conversion_type = 3, (cv.price * cv.count), 0))             AS indirect_sales,
  COUNT(DISTINCT IF(conversion_type IN (1, 2), cv.order_code, NULL)) AS direct_sales_count,
  COUNT(DISTINCT IF(conversion_type = 3, cv.order_code, NULL))       AS indirect_sales_count,
  SUM(IF(conversion_type IN (1, 2), cv.count, 0))                    AS direct_product_count,
  SUM(IF(conversion_type = 3, cv.count, 0))                          AS indirect_product_count
  FROM sns_snaps AS s
  LEFT JOIN
  sns_snap_conversions AS cv ON cv.sns_snap_id = s.id
  WHERE cv.date BETWEEN CONCAT(@date, ' 00:00:00') AND CONCAT(@date, ' 23:59:59')
  AND cv.brand_id = IF(@brand_id = 0, cv.brand_id, @brand_id)
  GROUP BY cv.brand_id, s.id) AS cv
  LEFT JOIN(SELECT s.id          AS sns_snap_id,
  s.brand_id,
  SUM(pv.count) AS `count`
  FROM sns_snaps AS s
  LEFT JOIN
  daily_pv AS pv ON pv.coordinate_id = s.id
  WHERE pv.content_type = 13
  AND pv.date BETWEEN CONCAT(@date, ' 00:00:00') AND CONCAT(@date, ' 23:59:59')
  AND pv.brand_id = IF(@brand_id = 0, pv.brand_id, @brand_id)
  GROUP BY s.id, s.brand_id) AS pv ON cv.sns_snap_id = pv.sns_snap_id
UNION
-- cvにpvをRIGHT JOIN
SELECT pv.brand_id,
       pv.sns_snap_id                                                      AS sns_snap_id,
       IF(cv.direct_sales IS NULL, 0, cv.direct_sales)                     AS direct_sales,
       IF(cv.indirect_sales IS NULL, 0, cv.indirect_sales)                 AS indirect_sales,
       IF(cv.direct_sales_count IS NULL, 0, cv.direct_sales_count)         AS direct_sales_count,
       IF(cv.indirect_sales_count IS NULL, 0, cv.indirect_sales_count)     AS indirect_sales_count,
       IF(cv.direct_product_count IS NULL, 0, cv.direct_product_count)     AS direct_product_count,
       IF(cv.indirect_product_count IS NULL, 0, cv.indirect_product_count) AS indirect_product_count,
       pv.count                                                            AS pv,
       @date                                                               AS date
FROM (SELECT cv.brand_id,
  s.id                                                               AS sns_snap_id,
  SUM(IF(conversion_type IN (1, 2), (cv.price * cv.count), 0))       AS direct_sales,
  SUM(IF(conversion_type = 3, (cv.price * cv.count), 0))             AS indirect_sales,
  COUNT(DISTINCT IF(conversion_type IN (1, 2), cv.order_code, NULL)) AS direct_sales_count,
  COUNT(DISTINCT IF(conversion_type = 3, cv.order_code, NULL))       AS indirect_sales_count,
  SUM(IF(conversion_type IN (1, 2), cv.count, 0))                    AS direct_product_count,
  SUM(IF(conversion_type = 3, cv.count, 0))                          AS indirect_product_count
  FROM sns_snaps AS s
  LEFT JOIN
  sns_snap_conversions AS cv ON cv.sns_snap_id = s.id
  WHERE cv.date BETWEEN CONCAT(@date, ' 00:00:00') AND CONCAT(@date, ' 23:59:59')
  AND cv.brand_id = IF(@brand_id = 0, cv.brand_id, @brand_id)
  GROUP BY cv.brand_id,
  s.id) AS cv
  RIGHT JOIN
  (SELECT s.id          AS sns_snap_id,
  s.brand_id,
  SUM(pv.count) AS `count`
  FROM sns_snaps AS s
  LEFT JOIN
  daily_pv AS pv ON pv.coordinate_id = s.id
  WHERE pv.content_type = 13
  AND pv.date BETWEEN CONCAT(@date, ' 00:00:00') AND CONCAT(@date, ' 23:59:59')
  AND pv.brand_id = IF(@brand_id = 0, pv.brand_id, @brand_id)
  GROUP BY s.id, s.brand_id) AS pv ON cv.sns_snap_id = pv.sns_snap_id;

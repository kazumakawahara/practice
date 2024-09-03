SELECT sd.sns_snap_id        AS sns_snap_id,
       SUM(sd.sales)         AS sales,
       SUM(sd.sales_count)   AS sales_count,
       SUM(sd.product_count) AS product_count,
       SUM(sd.pv)            AS pv,
       ssv.tracking_code     AS tracking_code,
       ssv.created_at        AS created_at
FROM ssvia_sns_snap_daily_sales AS sd
       INNER JOIN ssvia_sns_snaps AS ssv ON ssv.sns_snap_id = sd.sns_snap_id
WHERE sd.brand_id = 1
  AND (sd.date BETWEEN '2024-08-01 00:00:00' AND '2024-08-07 00:00:00')
  AND
  sd.sns_snap_id IN (SELECT sns_snaps.id FROM `sns_snaps` WHERE sns_snaps.sns_type = 1 AND sns_snaps.sns_user_id = 1)
GROUP BY `sd`.`sns_snap_id`
ORDER BY SUM(sd.sales) DESC, SUM(sd.pv) DESC
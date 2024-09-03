INSERT
INTO helper_daily_pv(brand_id,
                     helper_brand_id,
                     helper_label_id,
                     helper_shop_id,
                     helper_user_id,
                     content_type,
                     coordinate_id,
                     helper_coordinate_id,
                     date,
                     count,
                     device)
SELECT brand_id,
       helper_brand_id,
       label_id                        AS helper_label_id,
       shop_id                         AS helper_shop_id,
       user_id                         AS helper_user_id,
       content_type,
       CAST(coordinate_id AS UNSIGNED) AS content_id,
       CAST(coordinate_id AS UNSIGNED) AS helper_coordinate_id,
       @date as date,
        COUNT(*) as count,
        device
FROM
  pvs as pvs
WHERE
  created_at BETWEEN CONCAT(@date
    , ' 00:00:00')
  AND CONCAT(@date
    , ' 23:59:59')
  AND helper_brand_id
    > 0
  AND brand_id = CASE WHEN @brand_id = 0 THEN pvs.brand_id ELSE @brand_id
END
    GROUP BY
        brand_id,
        label_id,
        shop_id,
        user_id,
        helper_brand_id,
        content_type,
        coordinate_id,
        device
ON DUPLICATE KEY
UPDATE
  count =
VALUES (count)
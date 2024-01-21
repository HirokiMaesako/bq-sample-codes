/*
  BQで当月か、前月か、今会計年度(3月始まりか)を判定するためのCTE
*/

WITH const AS(
  SELECT
    target_date,
    IFNULL(DATE_TRUNC(target_date, MONTH) = DATE_TRUNC(CURRENT_DATE('Asia/Tokyo'), MONTH), FALSE) AS is_this_month,
    IFNULL(DATE_TRUNC(target_date, MONTH) = DATE_SUB(DATE_TRUNC(CURRENT_DATE('Asia/Tokyo'), MONTH), INTERVAL 1 MONTH), FALSE) AS is_last_month,
    IFNULL(DATE_TRUNC(target_date, MONTH) BETWEEN
      IF(EXTRACT(MONTH FROM CURRENT_DATE('Asia/Tokyo')) IN (1,2,3),
        DATE_ADD(DATE_SUB(DATE_TRUNC(CURRENT_DATE('Asia/Tokyo'), YEAR), INTERVAL 1 YEAR), INTERVAL 3 MONTH),
        DATE_ADD(DATE_TRUNC(CURRENT_DATE('Asia/Tokyo'), YEAR), INTERVAL 3 MONTH))
      AND
      IF(EXTRACT(MONTH FROM CURRENT_DATE('Asia/Tokyo')) IN (1,2,3),
        DATE_ADD(DATE_SUB(DATE_TRUNC(CURRENT_DATE('Asia/Tokyo'), YEAR), INTERVAL 1 YEAR), INTERVAL 15 MONTH) - 1,
        DATE_ADD(DATE_TRUNC(CURRENT_DATE('Asia/Tokyo'), YEAR), INTERVAL 15 MONTH) -1)
    , FALSE) AS is_financial_year_month,
  FROM
    (SELECT GENERATE_DATE_ARRAY(CURRENT_DATE('Asia/Tokyo') - 366 , CURRENT_DATE('Asia/Tokyo')) AS target_dates) AS date_array,
    UNNEST(target_dates) AS target_date
)
SELECT * FROM const

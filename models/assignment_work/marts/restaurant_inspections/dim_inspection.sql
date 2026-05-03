WITH all_inspections AS (
    SELECT DISTINCT
        CAST(inspection_date AS DATE) AS inspection_date,
        inspection_type
    FROM {{ ref('stg_nyc_restaurant_inspection') }}
    WHERE inspection_date IS NOT NULL
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['inspection_date', 'inspection_type']) }} AS inspection_key,
    inspection_date,
    inspection_type,
    EXTRACT(YEAR FROM inspection_date) AS year,
    EXTRACT(MONTH FROM inspection_date) AS month,
    EXTRACT(DAY FROM inspection_date) AS day_of_month
FROM all_inspections

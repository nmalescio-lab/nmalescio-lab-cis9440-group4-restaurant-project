WITH all_inspections AS (
    SELECT DISTINCT
        inspection_date,
        inspection_type
    FROM {{ ref('stg_nyc_restaurant_inspection') }}
    WHERE inspection_date IS NOT NULL
),
inspection_dimension AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['inspection_date', 'inspection_type']) }} AS inspection_key,
        inspection_date,
        inspection_type,
        EXTRACT(YEAR FROM inspection_date) AS year,
        EXTRACT(QUARTER FROM inspection_date) AS quarter,
        EXTRACT(MONTH FROM inspection_date) AS month,
        FORMAT_DATE('%B', inspection_date) AS month_name,
        EXTRACT(DAY FROM inspection_date) AS day_of_month,
        EXTRACT(DAYOFWEEK FROM inspection_date) AS day_of_week,
        FORMAT_DATE('%A', inspection_date) AS day_name,
        EXTRACT(DAYOFWEEK FROM inspection_date) IN (1, 7) AS is_weekend,
        CASE
            WHEN EXTRACT(MONTH FROM inspection_date) >= 7 THEN EXTRACT(YEAR FROM inspection_date) + 1
            ELSE EXTRACT(YEAR FROM inspection_date)
        END AS fiscal_year
    FROM all_inspections
)
SELECT * FROM inspection_dimension
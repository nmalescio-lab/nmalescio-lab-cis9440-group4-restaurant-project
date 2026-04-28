-- 311 status dimension
-- One row per service request status

WITH source AS (
    SELECT *
    FROM {{ ref('stg_nyc_311_restaurant') }}
),

status_dimension AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['status']) }} AS status_key,
        status
    FROM source
    WHERE status IS NOT NULL
)

SELECT *
FROM status_dimension
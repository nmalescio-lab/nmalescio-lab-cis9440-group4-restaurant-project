-- 311 agency dimension
-- One row per agency

WITH source AS (
    SELECT *
    FROM {{ ref('stg_nyc_311_restaurant') }}
),

agency_dimension AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['agency_name']) }} AS agency_key,
        agency_name
    FROM source
    WHERE agency_name IS NOT NULL
)

SELECT *
FROM agency_dimension
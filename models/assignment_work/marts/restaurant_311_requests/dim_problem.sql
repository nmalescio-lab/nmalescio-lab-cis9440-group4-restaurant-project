-- 311 problem dimension
-- One row per unique complaint/problem combination

WITH source AS (
    SELECT *
    FROM {{ ref('stg_nyc_311_restaurant') }}
),

problem_dimension AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key([
            'complaint_type',
            'descriptor',
            'descriptor_2'
        ]) }} AS problem_key,

        complaint_type AS problem,
        descriptor AS problem_detail,
        descriptor_2 AS additional_details

    FROM source
    WHERE complaint_type IS NOT NULL
)

SELECT *
FROM problem_dimension
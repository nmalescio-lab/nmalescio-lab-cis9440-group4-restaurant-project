WITH inspections AS (
    SELECT *
    FROM {{ ref('stg_nyc_restaurant_inspection') }}
),

dim_inspection_date AS (
    SELECT
        date_key,
        full_date
    FROM {{ ref('dim_date') }}
),

dim_grade_date AS (
    SELECT
        date_key,
        full_date
    FROM {{ ref('dim_date') }}
),

dim_restaurant AS (
    SELECT
        restaurant_key,
        camis
    FROM {{ ref('dim_restaurant') }}
),

dim_location AS (
    SELECT
        location_key,
        borough,
        zipcode
    FROM {{ ref('dim_location') }}
),

dim_violation AS (
    SELECT
        violation_key,
        violation_code,
        violation_desc
    FROM {{ ref('dim_violation') }}
),

dim_results AS (
    SELECT
        results_key,
        score,
        grade
    FROM {{ ref('dim_results') }}
),

dim_inspection AS (
    SELECT
        inspection_key,
        inspection_type
    FROM {{ ref('dim_inspection') }}
),

final AS (
    SELECT
        -- Primary key for this fact table
        {{ dbt_utils.generate_surrogate_key([
            'i.camis',
            'i.inspection_date',
            'i.inspection_type',
            'i.violation_code'
        ]) }} AS fact_inspection_key,

        -- Natural/source key
        i.camis AS restaurant_case_id,

        -- Foreign keys
        id.date_key AS inspection_date_key,
        gd.date_key AS grade_date_key,
        r.restaurant_key,
        l.location_key,
        v.violation_key,
        res.results_key,
        insp.inspection_key,

        -- Degenerate/detail fields from the inspection source
        i.dba AS restaurant_name,
        i.phone,
        i.cuisine_description,
        i.building,
        i.street,
        i.bbl,
        i.longitude,
        i.latitude

    FROM inspections i

    LEFT JOIN dim_inspection_date id
        ON DATE(SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E*S', i.inspection_date)) = id.full_date

    LEFT JOIN dim_grade_date gd
        ON DATE(SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E*S', i.grade_date)) = gd.full_date

    LEFT JOIN dim_restaurant r
        ON CAST(i.camis AS STRING) = CAST(r.camis AS STRING)

    LEFT JOIN dim_location l
        ON COALESCE(i.boro, '') = COALESCE(l.borough, '')
       AND COALESCE(CAST(i.zipcode AS STRING), '') = COALESCE(CAST(l.zipcode AS STRING), '')

    LEFT JOIN dim_violation v
        ON COALESCE(i.violation_code, '') = COALESCE(v.violation_code, '')
       AND COALESCE(i.violation_description, '') = COALESCE(v.violation_desc, '')

    LEFT JOIN dim_results res
        ON COALESCE(CAST(i.score AS STRING), '') = COALESCE(CAST(res.score AS STRING), '')
       AND COALESCE(i.grade, '') = COALESCE(res.grade, '')

    LEFT JOIN dim_inspection insp
        ON COALESCE(i.inspection_type, '') = COALESCE(insp.inspection_type, '')
)

SELECT *
FROM final
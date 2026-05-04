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
        restaurant_name,
        phone,
        cuisine_type,
        full_address,
        building_number,
        street_name,
        bbl,
        longitude,
        latitude
    FROM {{ ref('dim_restaurant') }}
),

dim_location AS (
    SELECT
        location_key,
        borough,
        zip_code,
        community_board,
        council_district,
        census_tract
    FROM {{ ref('dim_location') }}
),

dim_violation AS (
    SELECT
        violation_key,
        violation_code,
        violation_desc,
        is_critical
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
        inspection_type_key,
        inspection_type
    FROM {{ ref('dim_inspection') }}
),

final AS (
    SELECT
        -- Primary key for this fact table
        {{ dbt_utils.generate_surrogate_key(['i.inspection_id']) }} AS inspection_key,

        -- Natural/source key
        i.inspection_id,

        -- Foreign keys
        id.date_key AS inspection_date_key,
        gd.date_key AS grade_date_key,
        r.restaurant_key,
        l.location_key,
        v.violation_key,
        res.results_key,
        insp.inspection_type_key

    FROM inspections i

    LEFT JOIN dim_inspection_date id
        ON CAST(i.inspection_date AS DATE) = id.full_date

    LEFT JOIN dim_grade_date gd
        ON CAST(i.grade_date AS DATE) = gd.full_date

    LEFT JOIN dim_restaurant r
        ON COALESCE(i.restaurant_name, '') = COALESCE(r.restaurant_name, '')
       AND COALESCE(CAST(i.phone_number AS STRING), '') = COALESCE(CAST(r.phone AS STRING), '')
       AND COALESCE(i.cuisine_type, '') = COALESCE(r.cuisine_type, '')
       AND COALESCE(i.full_address, '') = COALESCE(r.full_address, '')

    LEFT JOIN dim_location l
        ON COALESCE(i.borough, '') = COALESCE(l.borough, '')
       AND COALESCE(CAST(i.zip_code AS STRING), '') = COALESCE(CAST(l.zip_code AS STRING), '')
       AND COALESCE(CAST(i.community_board AS STRING), '') = COALESCE(CAST(l.community_board AS STRING), '')
       AND COALESCE(CAST(i.council_district AS STRING), '') = COALESCE(CAST(l.council_district AS STRING), '')
       AND COALESCE(CAST(i.census_tract AS STRING), '') = COALESCE(CAST(l.census_tract AS STRING), '')

    LEFT JOIN dim_violation v
        ON COALESCE(i.violation_code, '') = COALESCE(v.violation_code, '')
       AND COALESCE(i.violation_desc, '') = COALESCE(v.violation_desc, '')
       AND COALESCE(CAST(i.is_critical AS STRING), '') = COALESCE(CAST(v.is_critical AS STRING), '')

    LEFT JOIN dim_results res
        ON COALESCE(CAST(i.score AS STRING), '') = COALESCE(CAST(res.score AS STRING), '')
       AND COALESCE(i.grade, '') = COALESCE(res.grade, '')

    LEFT JOIN dim_inspection insp
        ON COALESCE(i.inspection_type, '') = COALESCE(insp.inspection_type, '')
)

SELECT *
FROM final
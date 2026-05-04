WITH requests AS (
    SELECT *
    FROM {{ ref('stg_nyc_311_restaurant') }}
),

dim_open_date AS (
    SELECT
        date_key,
        full_date
    FROM {{ ref('dim_date') }}
),

dim_closed_date AS (
    SELECT
        date_key,
        full_date
    FROM {{ ref('dim_date') }}
),

dim_agency AS (
    SELECT
        agency_key,
        agency_name
    FROM {{ ref('dim_agency') }}
),

dim_problem AS (
    SELECT
        problem_key,
        problem,
        problem_detail,
        additional_details
    FROM {{ ref('dim_problem') }}
),

dim_status AS (
    SELECT
        status_key,
        status
    FROM {{ ref('dim_status') }}
),

dim_locationtype AS (
    SELECT
        locationtype_key,
        location_type
    FROM {{ ref('dim_locationtype') }}
),

dim_location AS (
    SELECT
        location_key,
        borough,
        zipcode
    FROM {{ ref('dim_location') }}
),

final AS (
    SELECT
        -- Primary key for this fact table
        {{ dbt_utils.generate_surrogate_key(['r.request_id']) }} AS service_request_key,
        r.request_id AS request_case_id,
        -- Foreign keys
        od.date_key AS open_date_key,
        cd.date_key AS closed_date_key,
        a.agency_key,
        l.location_key,
        p.problem_key,
        s.status_key,
        lt.locationtype_key,
        r.incident_address,
        r.street_name,
        r.bbl,
        r.longitude,
        r.latitude,
    FROM requests r

    LEFT JOIN dim_open_date od
        ON CAST(r.created_date AS DATE) = od.full_date

    LEFT JOIN dim_closed_date cd
        ON CAST(r.closed_date AS DATE) = cd.full_date

    LEFT JOIN dim_agency a
        ON COALESCE(r.agency_name, '') = COALESCE(a.agency_name, '')

    LEFT JOIN dim_location l
        ON COALESCE(r.borough, '') = COALESCE(l.borough, '')
       AND COALESCE(CAST(r.incident_zip AS STRING), '') = COALESCE(CAST(l.zipcode AS STRING), '')

    LEFT JOIN dim_problem p
        ON COALESCE(r.complaint_type, '') = COALESCE(p.problem, '')
       AND COALESCE(r.descriptor, '') = COALESCE(p.problem_detail, '')
       AND COALESCE(r.resolution_description, '') = COALESCE(p.additional_details, '')

    LEFT JOIN dim_status s
        ON COALESCE(r.status, '') = COALESCE(s.status, '')

    LEFT JOIN dim_locationtype lt
        ON COALESCE(r.location_type, '') = COALESCE(lt.location_type, '')
)

SELECT *
FROM final
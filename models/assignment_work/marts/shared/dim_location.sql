WITH all_locations AS (

   -- Get locations from 311 requests
   SELECT DISTINCT 
       CAST(borough AS STRING) AS borough,
       CAST(incident_zip AS INT64) AS zipcode,
       CAST(location_type AS STRING) AS location_type,
       CAST(REGEXP_EXTRACT(community_board, r'^\d+') AS INT64) AS community_board,
       CAST(council_district AS INT64) AS council_district,
       CAST(NULL AS STRING) AS census_tract

   FROM {{ ref('stg_nyc_311_restaurant') }}
   WHERE borough IS NOT NULL

   UNION DISTINCT

   -- Get locations from restaurant inspections
   SELECT DISTINCT 
       CAST(boro AS STRING) AS borough,
       CAST(zipcode AS INT64) AS zipcode,
       CAST(NULL AS STRING) AS location_type,
       CAST(community_board AS INT64) AS community_board,
       CAST(council_district AS INT64) AS council_district,
       CAST(census_tract AS STRING) AS census_tract

   FROM {{ ref('stg_nyc_restaurant_inspection') }}
   WHERE boro IS NOT NULL
),

location_dimension AS (
   SELECT
       {{ dbt_utils.generate_surrogate_key([
           'borough',
           'zipcode',
           'location_type',
           'community_board',
           'council_district',
           'census_tract'
       ]) }} AS location_key,

       borough,
       zipcode,
       location_type,
       community_board,
       council_district,
       census_tract

   FROM all_locations
   WHERE borough IS NOT NULL
)

SELECT * FROM location_dimension
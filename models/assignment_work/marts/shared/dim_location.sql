WITH all_locations AS (

   -- Get locations from 311 requests
   SELECT DISTINCT 
       CAST(borough AS STRING) AS borough,
       CAST(incident_zip AS INT64) AS zipcode,
       CAST(REGEXP_EXTRACT(community_board, r'^\d+') AS INT64) AS community_board,
       CAST(council_district AS INT64) AS council_district,
       CAST(NULL AS STRING) AS census_tract

   FROM {{ ref('stg_nyc_311_restaurant') }}
   WHERE borough IS NOT NULL
   AND CAST(borough AS STRING) != '0'

   UNION DISTINCT

   -- Get locations from restaurant inspections
   SELECT DISTINCT 
       CAST(boro AS STRING) AS borough,
       CAST(zipcode AS INT64) AS zipcode,
       CAST(community_board AS INT64) AS community_board,
       CAST(council_district AS INT64) AS council_district,
       CAST(census_tract AS STRING) AS census_tract

   FROM {{ ref('stg_nyc_restaurant_inspection') }}
   WHERE boro IS NOT NULL
   AND CAST(boro AS STRING) != '0'
),

location_dimension AS (
   SELECT
       {{ dbt_utils.generate_surrogate_key([
           'borough',
           'zipcode',
           'community_board',
           'council_district',
           'census_tract'
       ]) }} AS location_key,

       borough,
       zipcode,
       community_board,
       council_district,
       census_tract

   FROM all_locations
   WHERE borough IS NOT NULL
   AND borough != '0'
)

SELECT * FROM location_dimension
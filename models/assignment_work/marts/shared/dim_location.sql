WITH all_locations AS (
   -- Get locations from 311 requests
   SELECT DISTINCT CAST(borough AS STRING) AS borough,
   CAST(incident_zip AS INT) AS zipcode,
   CAST(location_type AS STRING) AS location_type,
   CAST(community_board AS STRING) AS community_board,
   CAST(council_district AS STRING) AS council_district,
   CAST(census_tract AS STRING) AS census_tract,
   CAST(incident_address AS STRING) AS address,
   CAST(street_name AS STRING) AS street_name,
   CAST(bbl AS STRING) AS bbl,
   CAST(longitude AS INT) AS longitude,
   CAST(latitude AS INT) AS latitude
   

   FROM {{ ref('stg_nyc_311_restaurant') }}
   WHERE borough IS NOT NULL

   UNION DISTINCT

   -- Get dates from restaurant applications
   SELECT DISTINCT CAST(boro AS STRING) AS borough,
   CAST(zipcode AS INT) AS zipcode,
   CAST(community_board AS STRING) AS community_board,
   CAST(council_district AS STRING) AS council_district,
   CAST(census_tract AS STRING) AS census_tract,
   CAST(building AS STRING) AS building_number,
   CAST(street AS STRING) AS street_name,
   CAST(bbl AS STRING) AS bbl,
   CAST(longitude AS INT) AS longitude,
   CAST(latitude AS INT) AS latitude
   FROM {{ ref('stg_nyc_restaurant_inspection') }}
   WHERE borough IS NOT NULL
),

location_dimension AS (
   SELECT
       {{ dbt_utils.generate_surrogate_key(['full_date']) }} AS date_key,

       full_date,
       EXTRACT(YEAR FROM full_date) AS year,
       EXTRACT(QUARTER FROM full_date) AS quarter,
       EXTRACT(MONTH FROM full_date) AS month,
       FORMAT_DATE('%B', full_date) AS month_name,
       CASE
           WHEN EXTRACT(MONTH FROM full_date) IN (12, 1, 2) THEN 'Winter'
           WHEN EXTRACT(MONTH FROM full_date) IN (3, 4, 5) THEN 'Spring'
           WHEN EXTRACT(MONTH FROM full_date) IN (6, 7, 8) THEN 'Summer'
           WHEN EXTRACT(MONTH FROM full_date) IN (9, 10, 11) THEN 'Fall'
       END AS season,
       EXTRACT(DAY FROM full_date) AS day_of_month,
       EXTRACT(DAYOFWEEK FROM full_date) AS day_of_week,
       FORMAT_DATE('%A', full_date) AS day_name,
       EXTRACT(DAYOFWEEK FROM full_date) IN (1, 7) AS is_weekend,
       CASE
           WHEN EXTRACT(MONTH FROM full_date) >= 7 THEN EXTRACT(YEAR FROM full_date) + 1
           ELSE EXTRACT(YEAR FROM full_date)
       END AS fiscal_year
   FROM all_dates
   WHERE full_date IS NOT NULL
)

SELECT * FROM date_dimension
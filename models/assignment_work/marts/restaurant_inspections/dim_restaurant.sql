WITH all_restaurants AS (
    SELECT DISTINCT
        camis,
        dba,
        cuisine_description,
        phone,
        building,
        street,
        zipcode,
        boro
    FROM {{ ref('stg_nyc_restaurant_inspection') }}
    WHERE camis IS NOT NULL
),
restaurant_dimension AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['camis']) }} AS restaurant_key,
        camis AS restaurant_id,
        dba AS restaurant_name,
        cuisine_description AS cuisine_type,
        phone,
        building AS building_number,
        street AS street_name,
        zipcode AS zip_code,
        boro AS borough
    FROM all_restaurants
)
SELECT * FROM restaurant_dimension

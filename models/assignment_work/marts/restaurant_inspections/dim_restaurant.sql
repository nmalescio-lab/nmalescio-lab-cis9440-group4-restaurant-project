WITH all_restaurants AS (
    SELECT DISTINCT
        camis,
        dba AS restaurant_name,
        cuisine_description AS cuisine_type,
        phone,
        building AS building_number,
        street AS street_name,
        CONCAT(building, ' ', street, ', ', boro, ', NY ', zipcode) AS full_address,
        zipcode AS zip_code,
        boro AS borough,
        bbl,
        longitude,
        latitude
    FROM {{ ref('stg_nyc_restaurant_inspection') }}
    WHERE camis IS NOT NULL
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['camis']) }} AS restaurant_key,
    camis AS restaurant_id,
    restaurant_name,
    cuisine_type,
    phone,
    building_number,
    street_name,
    full_address,
    zip_code,
    borough,
    bbl,
    longitude,
    latitude
FROM all_restaurants
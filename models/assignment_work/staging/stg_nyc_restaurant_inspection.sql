WITH source AS (
    SELECT * FROM {{ source('raw', 'source_restaurant_health_inspections') }}
),

cleaned AS (
    SELECT
        * EXCEPT (dba, street, phone, zipcode),

        -- DBA: Title Case
        INITCAP(TRIM(CAST(dba AS STRING))) AS dba,

        -- Street: Title Case
        INITCAP(TRIM(CAST(street AS STRING))) AS street,

        -- Phone: digits only + must be exactly 10 digits
        CASE
            WHEN LENGTH(REGEXP_REPLACE(CAST(phone AS STRING), r'[^0-9]', '')) = 10
            THEN REGEXP_REPLACE(CAST(phone AS STRING), r'[^0-9]', '')
            ELSE NULL
        END AS phone,

        -- Zipcode: must be exactly 5 digits
        CASE
            WHEN LENGTH(TRIM(CAST(zipcode AS STRING))) = 5
                 AND REGEXP_CONTAINS(TRIM(CAST(zipcode AS STRING)), r'^\d{5}$')
            THEN TRIM(CAST(zipcode AS STRING))
            ELSE NULL
        END AS zipcode,

        -- Metadata
        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source
)

SELECT * FROM cleaned
{{
    config(
        materialized='view'
    )
}}

with tripdata as 
(
  select *
  from {{ source('staging','fhv_tripdata') }}
  
)
select
    -- identifiers
    {{ dbt_utils.generate_surrogate_key(['dispatching_base_num', 'pickup_datetime']) }} as tripid,
    dispatching_base_num,

    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropOff_datetime as timestamp) as dropOff_datetime,

    {{ dbt.safe_cast("PUlocationID", api.Column.translate_type("integer")) }} as PUlocationID,
    {{ dbt.safe_cast("DOlocationID", api.Column.translate_type("integer")) }} as DOlocationID,
    
    SR_Flag,
    Affiliated_base_number
from tripdata

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
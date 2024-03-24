with
    stg_orders as (
        select
            orderid,
            {{ dbt_utils.generate_surrogate_key(["employeeid"]) }} as employeekey,
            {{ dbt_utils.generate_surrogate_key(["customerid"]) }} as customerkey,
            replace(to_date(orderdate)::varchar, '-', '')::int as orderdatekey
        from {{ source("northwind", "Orders") }}
    ),
    stg_order_details as (
        select
            orderid,
            {{ dbt_utils.generate_surrogate_key(["productid"]) }} as productkey,
            sum(quantity) as quantityonorder,
            sum(quantity * unitprice) as extendedpriceamount,
            sum(quantity * unitprice * discount) as discountamount,
            sum(
                (quantity * unitprice) - (quantity * unitprice * discount)
            ) as soldamount
        from {{ source("northwind", "Order_Details") }}
        group by orderid, productid
    )
select
    od.orderid,
    p.employeekey,
    p.customerkey,
    p.orderdatekey,
    od.productkey,
    od.quantityonorder,
    od.extendedpriceamount,
    od.discountamount,
    od.soldamount
from stg_orders p
join stg_order_details od on p.orderid = od.orderid

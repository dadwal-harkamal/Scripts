
/*Conditional join using case statement in 'on' clause in HiveQL
Let's say: the values in the column of tbl_A to join on have different lengths: 5 and 10. The values in the column of tbl_B to join on are larger length and when joining substr() should be applied depending on the length of the values in tble_A. So I was trying to apply a case statement in 'ON' clause when joining the tables using HiveQL, and I get following error:
Error while compiling statement: FAILED: SemanticException [Error 10017]: Line 22:3 Both left and right aliases encountered in JOIN '11'*/

Here is my code:

select  
a.fullname, b.birthdate from mydb.tbl_A a left join mydb.tbl_B b
on a.fullname = 
   case when length(a.fullname) = 5 then substr(b.othername,1,5)
   when length(a.fullname)= 9 then substr(b.othername, 8, 9) end
and a.birthdate = b.birthdate

I could not find much information on this. Your help will be much appreciated. Thank you.

/*JOIN currently has some limitations.
Here is a work-around.*/

select  a.fullname
       ,b.birthdate

from                tbl_A a

        left join   tbl_B b

        on          a.fullname  =  substr(b.othername,1,5) and a.birthdate = b.birthdate

where   length(a.fullname) <> 9
     or a.fullname is null

union all

select  a.fullname
       ,b.birthdate

from                tbl_A a

        left join   tbl_B b

        on          a.fullname  =  substr(b.othername,8,9) and a.birthdate = b.birthdate

where   length(a.fullname) = 9

--Ok, i have a following code to mark records that have highest month_cd in tabl with binary flag:

Select t1.month_cd, t2.max_month_cd
  ,CASE WHEN t2.max_month_cd != null then 0 else 1 end test_1
  ,CASE WHEN t2.max_month_cd = null then 0 else 1 end test_2
from source t1
Left join (
  Select 
    MAX(month_cd) as max_month_cd 
  From source 
) t2 
on t1.month_cd = t2.max_month_cd;

It seems straight forward to me, but result it return is:

month_cd  max_month_cd  test_1  test_2
201610    null          1       1
201611    201611        1       1

Makes zero sense to me, and seems to be way too obvious to be a bug in execution engine. What am i missing?

This is all about NULL concept.

/*Since Null is not a member of any data domain, it is not considered a "value", but rather a marker (or placeholder) indicating the absence of value. Because of this, comparisons 
with Null can never result in either True or False, but always in a third logical result, Unknown. NULL is nothing, absence of object. So, nothing can NOT be equal to NULL or 
something else. In SQL there are IS NULL and IS NOT NULL conditions to be used for test for null values.*/

In your CASE the result of logical expression is unknown, so ELSE value is assigned.

Corrected version:

CASE WHEN t2.max_month_cd IS NOT null then 0 else 1 end test_1,
CASE WHEN t2.max_month_cd IS null     then 0 else 1 end test_2

---------------------------------
SELECT DISTINCT C.sid
FROM Catalog C
WHERE NOT EXISTS ( SELECT *
                   FROM Parts P
                   WHERE P.pid = C.pid AND P.color <> ‘Red’)

If someone can help me get these into the correct Hive format I would really appreciate it.

Thank you.
----------------------------------
select distinct c.id
  from catalog c
  left outer join parts p
    on (c.pid = p.pid
   and p.color <> 'Red')
 where p.pid is null

-- enclosed on clause in () , this is not normally required of any major databases but seems to be needed in hiveql 
-- (https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Joins).
--Oh perfect! Works like a charm! Thank you so much. Could you put a link to the documentation you read? Thankyou! 


select case key
when 1 then 'one' 
when 2 then 'two' 
when 0 then 'zero' 
else 'out of range' 
end from hi_acid;

output:
_c0
out of range
one
out of range
two















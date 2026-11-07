Q1. Total Booking Records

---What is the total number of booking records available in the dataset?--- 
select count(*)as Total_Num_Bookings
from hotel_booking 

---Q2. Duplicate Records
Are there any duplicate booking records in the dataset? 
If yes, how many duplicate records are identified?--- 

select count(*) as Unique_records 
from
(select distinct* 
from hotel_booking)as unique_data 

SELECT
    (SELECT COUNT(*) FROM hotel_booking)
    -
    (SELECT COUNT(*)
     FROM (SELECT DISTINCT * FROM hotel_booking) AS unique_data)
    AS Duplicate_Records; 
    
    
    SELECT
    SUM(CASE WHEN country IS NULL OR country = 'NULL' OR TRIM(country) = '' THEN 1 ELSE 0 END) AS Country_Missing,
    SUM(CASE WHEN agent IS NULL OR agent = 'NULL' OR TRIM(agent) = '' THEN 1 ELSE 0 END) AS Agent_Missing,
    SUM(CASE WHEN company IS NULL OR company = 'NULL' OR TRIM(company) = '' THEN 1 ELSE 0 END) AS Company_Missing,
    SUM(CASE WHEN children IS NULL THEN 1 ELSE 0 END) AS Children_Missing
FROM hotel_booking; 

---Q4. Invalid Guest Counts
Are there any bookings where the number of adults, children,
 and babies is zero? Are there any negative guest counts?

SELECT
    SUM(CASE
        WHEN adults = 0
         AND children = 0
         AND babies = 0
        THEN 1 ELSE 0
    END) AS Zero_Guest_Bookings,

    SUM(CASE
        WHEN adults < 0
          OR children < 0
          OR babies < 0
        THEN 1 ELSE 0
    END) AS Negative_Guest_Bookings

FROM hotel_booking;

---Q5. ADR Validation
Are there any negative or unusually high ADR (Average Daily Rate) values?
 Identify and investigate those records. 
 SELECT *
FROM hotel_booking
WHERE adr < 0
   OR adr = (SELECT MAX(adr) FROM hotel_booking); 
   ---Q6. Stay Duration Analysis
Are there any bookings with zero or negative stay durations? 
Calculate the total stay duration using weekend and weekday nights.--- 
SELECT
    SUM(CASE
        WHEN stays_in_weekend_nights + stays_in_week_nights = 0
        THEN 1 ELSE 0
    END) AS Zero_Stay_Bookings,

    SUM(CASE
        WHEN stays_in_weekend_nights + stays_in_week_nights < 0
        THEN 1 ELSE 0
    END) AS Negative_Stay_Bookings,

    SUM(stays_in_weekend_nights + stays_in_week_nights)
        AS Total_Stay_Nights
FROM hotel_booking; 
---Q7. Booking Cancellation Analysis
What is the total number of canceled and non-canceled bookings?
Calculate the overall cancellation percentage.--- 

SELECT
    SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END)
        AS Canceled_Bookings,

    SUM(CASE WHEN is_canceled = 0 THEN 1 ELSE 0 END)
        AS Non_Canceled_Bookings,

    ROUND(
        SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS Cancellation_Percentage

FROM hotel_booking; 
---Q8. Hotel Type Comparison
Which hotel type, City Hotel or Resort Hotel, receives more bookings?
 Compare their total bookings and cancellation rates.--- 
SELECT
    hotel AS Hotel_Type,
    COUNT(*) AS Total_Bookings,
    SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END)
        AS Canceled_Bookings,
    ROUND(
        SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS Cancellation_Rate
FROM hotel_booking
GROUP BY hotel
ORDER BY Total_Bookings DESC; 
---Q9. Monthly Booking Trends
Which months have the highest and lowest number of bookings?
 Analyze booking patterns across different months.--- 
 
 -- Q9. Monthly Booking Trends

SELECT
    arrival_date_month AS Month,
    COUNT(*) AS Total_Bookings
FROM hotel_booking
GROUP BY arrival_date_month
ORDER BY FIELD(
    arrival_date_month,
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
);  
---Q10. Yearly Booking Trends
How many bookings were received in each year (2015, 2016, and 2017)?
 Identify the year with the highest number of bookings.--- 

SELECT
    arrival_date_year AS Year,
    COUNT(*) AS Total_Bookings
FROM hotel_booking
GROUP BY arrival_date_year
ORDER BY arrival_date_year; 
-0-Q11. Market Segment Analysis
Which market segments generate the highest number of bookings?
 Calculate the booking percentage for each market segment.--- 
 
 -- Q11. Market Segment Analysis

SELECT
    market_segment AS Market_Segment,
    COUNT(*) AS Total_Bookings,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM hotel_booking), 2
    ) AS Booking_Percentage
FROM hotel_booking
GROUP BY market_segment
ORDER BY Total_Bookings DESC; 
---Q12. Country-wise Booking Analysis
Identify the top 10 countries with the highest number of bookings.--- 

-- Q12. Country-wise Booking Analysis

SELECT
    country AS Country,
    COUNT(*) AS Total_Bookings
FROM hotel_booking
WHERE country IS NOT NULL
  AND country <> 'NULL'
  AND TRIM(country) <> ''
GROUP BY country
ORDER BY Total_Bookings DESC
LIMIT 10; 
---Q13. Lead Time and Cancellation Analysis
How does lead time affect booking cancellations? 
Group bookings into lead-time categories and compare their cancellation rates.--- 
SELECT
    CASE
        WHEN lead_time BETWEEN 0 AND 30 THEN '0-30 Days'
        WHEN lead_time BETWEEN 31 AND 90 THEN '31-90 Days'
        WHEN lead_time BETWEEN 91 AND 180 THEN '91-180 Days'
        ELSE 'Above 180 Days'
    END AS Lead_Time_Category,

    COUNT(*) AS Total_Bookings,

    SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END)
        AS Canceled_Bookings,

    ROUND(
        SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS Cancellation_Rate

FROM hotel_booking
WHERE lead_time >= 0
GROUP BY Lead_Time_Category
ORDER BY MIN(lead_time); 

---Q14. Repeat Guest Analysis
How many bookings were made by repeat guests versus new guests? 
Calculate the percentage of repeat guest bookings.--- 

-- Q14. Repeat Guest Analysis

SELECT
    SUM(CASE WHEN is_repeated_guest = 1 THEN 1 ELSE 0 END)
        AS Repeat_Guest_Bookings,

    SUM(CASE WHEN is_repeated_guest = 0 THEN 1 ELSE 0 END)
        AS New_Guest_Bookings,

    ROUND(
        SUM(CASE WHEN is_repeated_guest = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS Repeat_Guest_Percentage

FROM hotel_booking; 
---Q15. Monthly Cancellation Trends
Analyze monthly cancellation rates and identify the months with 
the highest and lowest cancellation percentages.--- 
SELECT
    arrival_date_month AS Month,
    COUNT(*) AS Total_Bookings,

    SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END)
        AS Canceled_Bookings,

    ROUND(
        SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS Cancellation_Rate

FROM hotel_booking

GROUP BY arrival_date_month

ORDER BY FIELD(
    arrival_date_month,
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
);









































































   
   
   
   
   
   
   
   
   


























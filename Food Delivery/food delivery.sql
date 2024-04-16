
#question 1
#What is the name of the restaurant with the longest average delivery time? And what is that time
#for each category of restaurant?
SELECT 
    RC.category_1, 
    R.Restaurant, 
    AVG(D.deliver_time) AS average_delivery_time
FROM 
    res_category RC
JOIN 
    Restaurant R ON RC.Res_ID = R.Res_ID
JOIN 
    Distance D ON R.Res_ID = D.Res_ID
GROUP BY 
    RC.category_1,  R.Restaurant
HAVING 
    AVG(D.deliver_time) = (
        SELECT MAX(average_delivery_time)
        FROM (
            SELECT 
                RC2.category_1, 
                AVG(D2.deliver_time) AS average_delivery_time
            FROM 
                res_category RC2
            JOIN 
                Distance D2 ON RC2.Res_ID = D2.Res_ID
            GROUP BY 
                RC2.category_1
        ) AS SubMax
        WHERE 
            SubMax.category_1 = RC.category_1
		And
            AVG(D.deliver_time) <> 0
    );

########################################################################

#question 2
WITH RankedRestaurants AS (
    SELECT 
        r.Restaurant,
        AVG(rev.star) AS AverageRating,
        p.Price_range,
        AVG(d.deliver_time) AS AverageDeliveryTime,
        ROW_NUMBER() OVER (
            PARTITION BY p.Price_range 
            ORDER BY AVG(rev.star) DESC
        ) AS Ranking
    FROM 
        Restaurant r
        INNER JOIN reviews rev ON r.Res_ID = rev.Res_ID
        INNER JOIN Price p ON r.Res_ID = p.Res_ID
        INNER JOIN City c ON r.CityID = c.CityID
        LEFT JOIN Distance d ON r.Res_ID = d.Res_ID
    WHERE 
        c.CityName = 'Toronto' -- Replace with the actual city name
    GROUP BY 
        r.Restaurant, p.Price_range, r.Res_ID
)
-- Follow this with the actual query using the RankedRestaurants CTE.


SELECT 
    Restaurant,
    AverageRating,
    Price_range,
    AverageDeliveryTime
FROM 
    RankedRestaurants
WHERE 
    Ranking <= 5
ORDER BY 
    Price_range, AverageRating DESC;
    
##############################################################

#question 3
#In which areas does a particular category of cuisine have low representation but high delivery demand, 
#indicating a potential market for restaurant expansion or introducing new cuisines?
#Find the top three cities and categories with the longest average delivery time (above the overall average) 
#and the number of restaurants in each category is below the average number of restaurants per category 
#(least representation) of restaurants per category
SELECT 
    CityCategory.CityName,
    CityCategory.category_1,
    CityCategory.AverageDeliveryTime,
    CityCategory.NumberOfRestaurants
FROM (
    SELECT 
        c.CityName,
        rc.category_1,
        AVG(d.deliver_time) AS AverageDeliveryTime,
        COUNT(DISTINCT r.Res_ID) AS NumberOfRestaurants
    FROM 
        Restaurant r
    JOIN 
        res_category rc ON r.Res_ID = rc.Res_ID
    JOIN 
        Distance d ON r.Res_ID = d.Res_ID
    JOIN 
        City c ON r.CityID = c.CityID
    GROUP BY 
        c.CityName, rc.category_1
) AS CityCategory
WHERE 
    CityCategory.AverageDeliveryTime > (SELECT AVG(deliver_time) FROM Distance)
    AND CityCategory.NumberOfRestaurants < (SELECT COUNT(*) / COUNT(DISTINCT category_1) FROM res_category)
ORDER BY 
    CityCategory.AverageDeliveryTime DESC, CityCategory.NumberOfRestaurants ASC
LIMIT 3;

##############################################################################
#question 4
#For each restaurant category, which cities have the highest and lowest performing restaurants based 
#on average reviews and delivery times? 
SELECT 
    rc.category_1,
    c.CityName,
    AVG(rev.star) AS AverageRating,
    AVG(d.deliver_time) AS AverageDeliveryTime,
    RANK() OVER (PARTITION BY rc.category_1 ORDER BY AVG(rev.star) DESC, AVG(d.deliver_time)) AS PerformanceRank
FROM 
    Restaurant r
JOIN 
    reviews rev ON r.Res_ID = rev.Res_ID
JOIN 
    Distance d ON r.Res_ID = d.Res_ID
JOIN 
    res_category rc ON r.Res_ID = rc.Res_ID
JOIN 
    City c ON r.CityID = c.CityID
GROUP BY 
    rc.category_1, c.CityName
ORDER BY 
    rc.category_1, PerformanceRank;

##########################################################################
#question 5
#Which premium-priced restaurants (in the top price range) have lower than average review ratings?
SELECT 
    r.Restaurant,
    p.Price_range,
    c.CityName,
    AVG(rev.star) AS AverageRating
FROM 
    Restaurant r
JOIN 
    Price p ON r.Res_ID = p.Res_ID
JOIN 
    City c ON r.CityID = c.CityID
JOIN 
    reviews rev ON r.Res_ID = rev.Res_ID
WHERE 
    p.Price_range = (SELECT MAX(Price_range) FROM Price) 
GROUP BY 
    r.Restaurant, p.Price_range, c.CityName
HAVING 
    AVG(rev.star) < (SELECT AVG(star) FROM reviews)
ORDER BY 
    AverageRating ASC;
    
###############################################################################

#question 6
#What is the difference in average delivery times between the top quartile and bottom 
#quartile restaurants in terms of review stars?
WITH RankedRestaurants AS (
    SELECT 
        r.Res_ID,
        AVG(rev.star) AS AverageStarRating,
        AVG(d.deliver_time) AS AverageDeliveryTime,
        NTILE(4) OVER (ORDER BY AVG(rev.star) DESC) AS Quartile
    FROM 
        reviews rev
        INNER JOIN Restaurant r ON rev.Res_ID = r.Res_ID
        INNER JOIN Distance d ON r.Res_ID = d.Res_ID
    GROUP BY 
        r.Res_ID
),
QuartileAverages AS (
    SELECT 
        Quartile,
        AVG(AverageDeliveryTime) AS QuartileAverageDeliveryTime
    FROM 
        RankedRestaurants
    GROUP BY 
        Quartile
)
SELECT 
    MAX(CASE WHEN Quartile = 1 THEN QuartileAverageDeliveryTime END) AS TopQuartileAvgDeliveryTime,
    MAX(CASE WHEN Quartile = 4 THEN QuartileAverageDeliveryTime END) AS BottomQuartileAvgDeliveryTime,
    (MAX(CASE WHEN Quartile = 1 THEN QuartileAverageDeliveryTime END) -
    MAX(CASE WHEN Quartile = 4 THEN QuartileAverageDeliveryTime END)) AS DifferenceInAvgDeliveryTime
FROM 
    QuartileAverages;

################################################################################
#question 7
#Which restaurant has the highest number of reviews, and how does this compare with the average 
#number of reviews per restaurant in the same city?
WITH CityReviewStats AS (
    SELECT 
        c.CityName,
        r.Restaurant,
        SUM(rev.num_reviews) AS TotalReviews,
        AVG(SUM(rev.num_reviews)) OVER (PARTITION BY c.CityName) AS CityAverageReviews
    FROM 
        Restaurant r
        JOIN reviews rev ON r.Res_ID = rev.Res_ID
        JOIN City c ON r.CityID = c.CityID
    GROUP BY 
        c.CityName, r.Restaurant
),
MaxReviewsPerCity AS (
    SELECT 
        CityName,
        Restaurant,
        TotalReviews,
        CityAverageReviews,
        RANK() OVER (PARTITION BY CityName ORDER BY TotalReviews DESC) AS ReviewRank
    FROM CityReviewStats
)
SELECT 
    CityName,
    Restaurant,
    TotalReviews,
    CityAverageReviews
FROM MaxReviewsPerCity
WHERE ReviewRank = 1;

#question 8
WITH RankedRestaurants AS (
    SELECT 
        r.Restaurant,
        AVG(rev.star) AS AverageRating,
        NTILE(4) OVER (ORDER BY AVG(rev.star) DESC) AS RatingQuartile
    FROM 
        Restaurant r
        JOIN reviews rev ON r.Res_ID = rev.Res_ID
    GROUP BY 
        r.Restaurant
)
SELECT 
    Restaurant,
    AverageRating,
    CASE 
        WHEN RatingQuartile = 1 THEN 'Excellent'
        WHEN RatingQuartile = 2 THEN 'Good'
        WHEN RatingQuartile = 3 THEN 'Average'
        ELSE 'Poor'
    END AS RatingCategory
FROM 
    RankedRestaurants;

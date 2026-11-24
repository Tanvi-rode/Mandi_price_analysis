CREATE DATABASE IF NOT EXISTS mandi_project;
USE mandi_project;

CREATE TABLE mandi_prices (
    State VARCHAR(50),
    District VARCHAR(50),
    Market VARCHAR(100),
    Commodity VARCHAR(50),
    Variety VARCHAR(100),
    Grade VARCHAR(50),
    Arrival_Date DATE,
    Min_Price DECIMAL(10, 2),
    Max_Price DECIMAL(10, 2),
    Modal_Price DECIMAL(10, 2),
    Price_Spread DECIMAL(10, 2),
    Price_Per_Kg DECIMAL(10, 2)
);


CREATE OR REPLACE VIEW vw_cheapest_markets AS
SELECT 
    Commodity,
    District,
    Market,
    ROUND(AVG(Price_Per_Kg), 2) AS Avg_Price_Kg,
    ROUND(MIN(Price_Per_Kg), 2) AS Lowest_Price_Kg,
    ROUND(AVG(Price_Spread), 2) AS Avg_Volatility,
    COUNT(*) AS Trading_Days
FROM mandi_prices
GROUP BY Commodity, District, Market;


CREATE OR REPLACE VIEW vw_daily_trends AS
SELECT 
    Arrival_Date,
    Commodity,
    District,
    ROUND(AVG(Price_Per_Kg), 2) AS Daily_Avg_Kg,
    ROUND(AVG(AVG(Price_Per_Kg)) OVER (
        PARTITION BY Commodity, District 
        ORDER BY Arrival_Date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS Rolling_7Day_Avg_Kg
FROM mandi_prices
GROUP BY Arrival_Date, Commodity, District;


CREATE OR REPLACE VIEW vw_price_spikes AS
SELECT 
    Arrival_Date,
    District,
    Market,
    Commodity,
    Price_Per_Kg,
    Price_Spread
FROM mandi_prices
WHERE Price_Spread > (
    SELECT AVG(Price_Spread) * 1.5 FROM mandi_prices
);

SELECT * FROM vw_cheapest_markets ORDER BY Commodity, Avg_Price_Kg ASC LIMIT 15;

/* Queries asked 1 to 4*/

-- This table is already Created
CREATE TABLE invests_in ( -- Running
  user_id BIGINT UNSIGNED NOT NULL,
  symbol VARCHAR(10) NOT NULL,
  quantity BIGINT NOT NULL,
  entry_price DOUBLE(10,2) NOT NULL,
  entry_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  percent_weight DOUBLE(5,2) NOT NULL,
  PRIMARY KEY  (user_id,symbol),
  FOREIGN KEY (user_id) 
    REFERENCES user (user_id) 
    ON DELETE RESTRICT 
    ON UPDATE CASCADE,
  FOREIGN KEY (symbol) 
    REFERENCES investment (symbol) 
    ON DELETE RESTRICT 
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE investment ( -- Running
  id VARCHAR(10) NOT NULL,
  name VARCHAR(45) NOT NULL,
  type ENUM ('Equity','Currency','Commodity','Mutual Funds'),
  current_price DOUBLE(10,2) NOT NULL,
  total_return DOUBLE (5,2),
  annualized_return DOUBLE (5,2),
  risk_level DOUBLE (5,2),
  PRIMARY KEY  (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



CREATE TABLE market_data ( -- Running
  symbol VARCHAR(10) NOT NULL,
  on_date TIMESTAMP NOT NULL,
  volume DOUBLE(10,2),
  open DOUBLE(10,2),
  close DOUBLE(10,2) NOT NULL,
  high DOUBLE(10,2),
  low DOUBLE(10,2),
  vwap DOUBLE(10,2),
  PRIMARY KEY (symbol,on_date),
  FOREIGN KEY (symbol) 
    REFERENCES investment (symbol)
    ON DELETE RESTRICT 
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



CREATE TABLE financial_info( -- Running
  date_of_data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  interest DOUBLE(5,2),
  inflation DOUBLE(5,2),
  gdp DOUBLE(5,2),
  PRIMARY KEY (date_of_data) 
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--@block Query 5 : Insert a new investment into the investments table.
INSERT INTO investment VALUES ('INFY','Infosys Pvt Ltd','Equity',1244.76,-3.02,-20.44,-0.16);
INSERT INTO invests_in VALUES (1,'INFY',30,200,'2023-04-10 02:22:49',20);

-- To check : select * from invests_in where symbol='INFY';

--@block Query 6 : Update the number of shares held for an investment in the investments table.
UPDATE invests_in
  SET quantity = 50 
  WHERE symbol = 'INFY' AND user_id = '1';

--@block Query 7 : Delete an investment from the investments table.
DELETE FROM investment WHERE symbol = 'INFY';

--@block Query 8 : Join the investments table with the performance metrics table to retrieve the total return for each investment.
SELECT * from viewallinvestments
WHERE user_id = 1;

--@block Query 9 : Join the investments table with the market data table to retrieve the stock prices for a particular date.
SELECT 
  market_data.on_date,
  investment.name,
  investment.symbol,
  investment.current_price,
  market_data.open,
  market_data.close,
  market_data.high,
  market_data.low
FROM investment
INNER JOIN market_data USING(symbol)
WHERE
  symbol = 'wkrpz' AND 
  on_date = '2023-04-03 '
;

--@block Query 10 : Group the investments by type and retrieve the average annualized return for each type.
SELECT 
  investment.type as 'Investment Type',
  AVG(annualized_return) as 'Average Annualized Return'
FROM investment
GROUP BY type;

--@block Query 11 : Filter the investments by risk level and retrieve the top-performing investments.
SELECT
 investment.name,
 investment.risk_level,
 que_risk(risk_level)
FROM investment
ORDER BY risk_level ASC;

--@block Query 12 : Calculate the total value of all investments based on the number of shares held and the current stock prices from the market data table.
SELECT 
  symbol,
  SUM(Invst_return) AS Total_Return
FROM viewallinvestments
GROUP BY symbol
;

SELECT
 symbol,
 total_return
FROM investment;

--@block Query 13 : Calculate the portfolio’s overall annualized return based on the investments’ individual returns and the number of shares held.
SELECT SUM(percent_weight*annualized_return)/100 as 'Percent Annualized Return'
FROM investment
INNER JOIN invests_in USING (symbol)
WHERE user_id=1
GROUP BY user_id;

-- Query 14




--@block Query 15 : Retrieve the most recent inflation rate from the other financial information table.
SELECT 
  date_of_data as 'Most Recent Date',
  inflation as 'Inflation Rate'
FROM financial_info
ORDER BY date_of_data DESC
LIMIT 1;

--@block Query 16 : Filter the market data table by date range and retrieve the stock prices for a particular investment.
SELECT * FROM market_data
WHERE symbol = 'batns'
ORDER BY on_date DESC;


--@block Query 17 : Calculate the percentage change in stock prices for a particular investment between two dates.
DELIMITER $$
  DROP FUNCTION IF EXISTS que_17; 
  CREATE FUNCTION que_17(input_start_date DATE, input_end_date DATE, input_symbol VARCHAR(50)) returns DOUBLE(10,2)
  DETERMINISTIC
  BEGIN
    DECLARE start_price DOUBLE(10,2);
    DECLARE end_price DOUBLE(10,2);
    
    SELECT high INTO start_price FROM market_data
    WHERE symbol = input_symbol AND on_date = input_start_date;
    
    SELECT high INTO end_price FROM market_data
    WHERE symbol = input_symbol AND on_date = input_end_date;

    RETURN (100*(start_price-end_price))/(start_price);
  END $$
DELIMITER ;


SELECT que_17('2023-04-02','2023-04-03','mpkbc');


--@block Query 18 : Calculate the volatility of an investment’s returns using the performance metrics table.
SELECT STDDEV(close)/100 as Volatility
from market_data
where symbol = 'batns'
GROUP BY symbol;


--@block Query 19 : Retrieve the top-performing investments based on annualized return and risk level.
SELECT * from investment
ORDER BY annualized_return/risk_level DESC;


--@block Query 20 : Group the investments by type and retrieve the total number of shares held for each type.
SELECT 
  investment.type as 'Investment Type',
  SUM(invests_in.quantity) as Quantity
FROM invests_in
INNER JOIN investment USING(symbol)
GROUP BY investment.type;

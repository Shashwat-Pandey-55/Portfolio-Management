use portfolio;

--
-- Procedures
--

DELIMITER //
  DROP PROCEDURE IF EXISTS addUser;
  CREATE PROCEDURE addUser(
                            IN in_email VARCHAR(45),
                            IN in_passwrd VARCHAR(50),
                            IN in_first_name VARCHAR(45),
                            IN in_last_name VARCHAR(45),
                            IN in_phone_number BIGINT,
                            IN in_pan_number VARCHAR(10)
                          )
  BEGIN
    insert into user(email, passwrd, first_name, last_name, phone_number, pan_number) 
    values (in_email, in_passwrd, in_first_name, in_last_name, in_phone_number, in_pan_number);
  END //
DELIMITER ;

DELIMITER //
  DROP PROCEDURE IF EXISTS addPerformance;
  CREATE PROCEDURE addPerformance(IN in_user_id BIGINT)
  BEGIN
    insert into portfolio_returns(user_id) 
    values (in_user_id);
  END //
DELIMITER ;

DELIMITER $$
  DROP PROCEDURE IF EXISTS update_total_return;
  CREATE PROCEDURE update_total_return()
  BEGIN
    DECLARE cursor_ID VARCHAR(50);
    DECLARE var_total_return DOUBLE(10,2);
    DECLARE done INT DEFAULT FALSE;
    DECLARE cursor_i CURSOR FOR SELECT symbol FROM investment;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cursor_i;
    read_loop: LOOP
      FETCH cursor_i INTO cursor_ID;
      IF done THEN
        LEAVE read_loop;
      END IF;
      UPDATE investment 
      SET total_return = totalReturnInvestment(cursor_ID) 
      WHERE symbol = cursor_ID;
    END LOOP;
    CLOSE cursor_i;
  END$$
DELIMITER ;

--
-- Functions
--

DELIMITER $$
  DROP FUNCTION IF EXISTS totalReturn; 
  CREATE FUNCTION totalReturn(input_user_id BIGINT UNSIGNED) returns DOUBLE(10,2)
  DETERMINISTIC
  BEGIN
    DECLARE var_total_return DOUBLE(10,2);
    
    SELECT SUM(invests_in.quantity*(investment.current_price-invests_in.entry_price))
    INTO var_total_return
    FROM invests_in
    INNER JOIN investment USING (symbol)
    WHERE invests_in.user_id = input_user_id;

    RETURN var_total_return;
  END $$
DELIMITER ;


DELIMITER $$
  DROP FUNCTION IF EXISTS totalReturnInvestment; 
  CREATE FUNCTION totalReturnInvestment(input_symbol VARCHAR(50)) returns DOUBLE(10,2)
  DETERMINISTIC
  BEGIN
    DECLARE var_total_return DOUBLE(10,2);
    
    SELECT SUM(Invst_return)
    INTO var_total_return
    FROM 
    (
      SELECT * FROM viewallinvestments
      INNER JOIN investment USING (symbol)
      WHERE investment.symbol = input_symbol
    ) AS output_all;

    RETURN var_total_return;
  END $$
DELIMITER ;


DELIMITER $$
  DROP FUNCTION IF EXISTS que_risk; 
  CREATE FUNCTION que_risk(input_risk DOUBLE(5,2)) returns VARCHAR(32)
  DETERMINISTIC
  BEGIN
    IF input_risk < 0.8 THEN
      RETURN 'LOW RISK';
    ELSEIF input_risk >= 0.8 AND input_risk < 1.1 THEN
      RETURN 'MEDUIM RISK';
    ELSE 
      RETURN 'HIGH RISK';
    END IF;
  END $$
DELIMITER ;

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

--
-- Views
--

DROP VIEW IF EXISTS viewAllReturns;
CREATE VIEW viewAllReturns AS
SELECT 
  user.user_id, user.first_name, totalReturn(user_id)
FROM user;


DROP VIEW IF EXISTS viewAllInvestments;
CREATE VIEW viewAllInvestments AS
  SELECT 
    invests_in.user_id AS user_id,
    CONCAT(user.first_name," ",user.last_name) AS User_Name,
    invests_in.symbol AS Symbol,
    investment.name AS Symbol_Name_View,
    invests_in.quantity AS Quantity_View,
    invests_in.entry_price AS Entry_Price_View,
    investment.current_price AS Current_Price_View,
    invests_in.quantity*(investment.current_price-invests_in.entry_price) AS Invst_return
  FROM invests_in
  INNER JOIN investment USING (symbol)
  INNER JOIN user USING (user_id)
  ORDER BY user_id;



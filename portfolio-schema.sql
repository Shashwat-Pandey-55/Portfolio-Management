DROP SCHEMA IF EXISTS portfolio;
CREATE SCHEMA portfolio;
USE portfolio;



CREATE TABLE user ( -- Running
  user_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(45) NOT NULL UNIQUE,
  passwrd VARCHAR(50) NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45),
  phone_number BIGINT UNSIGNED,
  pan_number VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE investment ( -- Running
  symbol VARCHAR(10) NOT NULL,
  name VARCHAR(45) NOT NULL,
  type ENUM ('Equity','Currency','Commodity','Mutual Funds') NOT NULL,
  current_price DOUBLE(10,2) NOT NULL,
  total_return DOUBLE (10,2),
  annualized_return DOUBLE (5,2),
  risk_level DOUBLE (5,2),
  PRIMARY KEY  (symbol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE invests_in ( -- Running
  user_id BIGINT UNSIGNED NOT NULL,
  symbol VARCHAR(10) NOT NULL,
  quantity BIGINT NOT NULL,
  entry_price DOUBLE(10,2) NOT NULL,
  entry_date DATE NOT NULL default(CURRENT_DATE),
  percent_weight DOUBLE(5,2) NOT NULL,
  PRIMARY KEY  (user_id,symbol),
  FOREIGN KEY (user_id) 
    REFERENCES user (user_id) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE,
  FOREIGN KEY (symbol) 
    REFERENCES investment (symbol) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE market_data ( -- Running
  symbol VARCHAR(10) NOT NULL,
  on_date DATE NOT NULL DEFAULT(CURRENT_DATE),
  volume DOUBLE(10,2),
  open DOUBLE(10,2),
  close DOUBLE(10,2) NOT NULL,
  high DOUBLE(10,2),
  low DOUBLE(10,2),
  vwap DOUBLE(10,2),
  PRIMARY KEY (symbol,on_date),
  FOREIGN KEY (symbol) 
    REFERENCES investment (symbol)
    ON DELETE CASCADE 
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE portfolio_returns( -- Running
  user_id BIGINT UNSIGNED,
  total_return DOUBLE(10,2) DEFAULT 0,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) 
    REFERENCES user(user_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



CREATE TABLE financial_info( -- Running
  date_of_data DATE NOT NULL DEFAULT(CURRENT_DATE),
  interest DOUBLE(5,2),
  inflation DOUBLE(5,2),
  gdp DOUBLE(5,2),
  PRIMARY KEY (date_of_data) 
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


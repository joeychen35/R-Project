CREATE DATABASE db_customer_panel;
USE db_customer_panel;

CREATE TABLE Households(
	hh_id    			BIGINT unsigned,
    hh_race  			INT(1),
    is_latinx 			INT(1),
    hh_income 			INT(2),  # Integer indicating the income bracket
    hh_size  			INT(1),  # Integer indicating the number of members composing the household
    hh_zip_code  		INT(5),
    hh_state  			VARCHAR(2),
    hh_residence_type   INT(1), 
    PRIMARY KEY  		(hh_id)
);

CREATE TABLE Products(
	brand_at_prod_id     	VARCHAR(100) DEFAULT NULL,
	department_at_prod_id   VARCHAR(100)DEFAULT NULL,
	prod_id               	BIGINT unsigned,
	group_at_prod_id      	VARCHAR(100)DEFAULT NULL,
	module_at_prod_id     	VARCHAR(100)DEFAULT NULL,
	amount_at_prod_id     	FLOAT DEFAULT NULL,
	units_at_prod_id      	VARCHAR(10)DEFAULT NULL,
	PRIMARY KEY 		  	(prod_id)
);

CREATE TABLE Trips(
	hh_id  							BIGINT unsigned,
    TC_date  						date,
    TC_retailer_code  				INT,
    TC_retailer_code_store_code     INT,
    TC_retailer_code_store_zip3  	FLOAT,
    TC_total_spent  				FLOAT,
    TC_id  							INT unsigned,
    PRIMARY KEY 					(TC_id),
    FOREIGN KEY (hh_id) REFERENCES Households(hh_id)
);

CREATE TABLE Purchases(
	TC_id  								INT unsigned,
    quantity_at_TC_prod_id  			INT,
    total_price_paid_at_TC_prod_id    	FLOAT,
    coupon_value_at_TC_prod_id  		FLOAT,
    deal_flag_at_TC_prod_id  			INT,
    prod_id  							BIGINT unsigned,
    FOREIGN KEY (TC_id) REFERENCES Trips(TC_id),
    FOREIGN KEY (prod_id) REFERENCES Products(prod_id)
);


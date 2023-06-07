create schema frostbyte_media.analytics;

CREATE TABLE dim_user (
  user_id number,
  is_migration boolean,
  first_start_timestamp timestamp_ntz,
  first_paid_start_timestamp timestamp_ntz,
  first_trial_start_timestamp timestamp_ntz,
  first_provider text,
  most_recent_subscription_start timestamp_ntz,
  has_had_trial boolean,
  has_had_cancel boolean,
  times_cancelled number,
  first_name text,
  last_name text,
  email_address text,
  billing_address variant,
  service_address variant,
  constraint pk primary key(user_id)
);


CREATE OR REPLACE TABLE dim_marketing_program (
  marketing_program_id number,
  program_name text,
  program_fiscal_data variant,
  program_budget text,
  constraint pk primary key(marketing_program_id)
);



CREATE OR REPLACE TABLE dim_marketing_campaign (
  marketing_campaign_id number,
  marketing_program_id number,
  campaign_name text,
  campaign_drop_date timestamp_ntz,
  campaign_end_date timestamp_ntz,
  constraint pk primary key(marketing_campaign_id),
  CONSTRAINT FK_dim_marketing_campaign
    FOREIGN KEY (marketing_program_id)
      REFERENCES dim_marketing_program(marketing_program_id)
  
);



CREATE TABLE dim_marketing_offer (
  offer_id number,
  offer_name text,
  offer_code text,
  offer_start_date timestamp_ntz,
  offer_expiration_date timestamp_ntz,
  offer_amount number(38,8),
  offer_cost number(38,8),
  redemption_code text,
  offer_sku_code text,
  constraint pk primary key(offer_id)
);



CREATE TABLE dim_marketing_cell (
  cell_id number,
  cell_name text,
  cell_code text,
  is_control boolean,
  control_cell_id number,
  constraint pk primary key(cell_id)
);



CREATE TABLE dim_marketing_channel (
  marketing_channel_id number,
  marketing_channel_name text,
  marketing_channel_group text,
  constraint pk primary key(marketing_channel_id)
);



CREATE OR REPLACE TABLE contact_history (
  contact_history_id number,
  user_id number,
  marketing_campaign_id number,
  cell_id number,
  offer_id number,
  contact_date timestamp_ntz,
  execution_date timestamp_ntz,
  marketing_channel_id number,
  constraint pk primary key(contact_history_id),
  CONSTRAINT FK_contact_history_offer_id
    FOREIGN KEY (offer_id)
      REFERENCES dim_marketing_offer(offer_id),
  CONSTRAINT FK_contact_history_marketing_campaign_id
    FOREIGN KEY (marketing_campaign_id)
      REFERENCES dim_marketing_campaign(marketing_campaign_id),
  CONSTRAINT FK_contact_history_cell_id
    FOREIGN KEY (cell_id)
      REFERENCES dim_marketing_cell(cell_id),
  CONSTRAINT FK_contact_history_marketing_channel_id
    FOREIGN KEY (marketing_channel_id)
      REFERENCES dim_marketing_channel(marketing_channel_id),
  CONSTRAINT FK_contact_history_user_id
    FOREIGN KEY (user_id)
      REFERENCES dim_user(user_id)
);



CREATE TABLE dim_response_channel (
  response_channel_id number,
  response_channel_name text,
  response_channel_group text,
  constraint pk primary key(response_channel_id)  
);



CREATE TABLE response_history (
  response_history_id number,
  promotion_history_id number,
  user_id number,
  response_date timestamp_ntz,
  response_type text,
  response_revenue number(38,8),
  response_cost number(38,8),
  response_channel_id number,
  fraction_attribution_amount number(38,8),
  constraint pk primary key(response_history_id),
  CONSTRAINT FK_response_history_response_history_id
    FOREIGN KEY (response_history_id)
      REFERENCES contact_history(contact_history_id),
  CONSTRAINT FK_response_history_response_channel_id
    FOREIGN KEY (response_channel_id)
      REFERENCES dim_response_channel(response_channel_id),
  CONSTRAINT FK_response_history_user_id
    FOREIGN KEY (user_id)
      REFERENCES dim_user(user_id)
);


CREATE OR REPLACE TABLE subscription_daily_summary (
  reporting_dt timestamp_ntz,
  sku_code text,
   country_code text,
   signups number,
   paid_signups number,
   trial_signups number,
   cancels number,
   paid_cancels number,
   trial_cancels number,
   subscriptions_eligible_to_renew number,
   paid_subscriptions_eligible_to_renew number,
   trial_subscriptions_eligible_to_renew number,
   paid_reconnects number,
   subscription_balance number(38,8),
   paid_subscription_balance number(38,8),
   trial_subscription_balance number(38,8),
   subscription_balance_prior_month number(38,8),
   paid_subscription_balance_prior_month number(38,8),
   trial_subscription_balance_prior_month number(38,8),
   constraint pk primary key(reporting_dt,sku_code)
);

CREATE OR REPLACE TABLE billing_cycle_retention_attributes (
  billing_cycle_id number,
  subscription_id number,
  user_id number,
   has_watched_new_release boolean,
   active_days number,
   has_customer_service_record boolean,
   has_application_error boolean,
   most_viewed_title text,
   hours_viewed number(38,8),
   constraint pk primary key(billing_cycle_id)
);


CREATE OR REPLACE TABLE dim_product (
  sku_code text,
   sku_name text,
   product_code text,
   product_type text,
   product_name text,
   product_group text,
   provider text,
   sku_launch_ts timestamp_ntz,
   constraint pk primary key(sku_code)
);

CREATE OR REPLACE TABLE dim_date (
   CAL_DT          DATE        NOT NULL
  ,YEAR             SMALLINT    NOT NULL
  ,MONTH            SMALLINT    NOT NULL
  ,MONTH_NAME       CHAR(3)     NOT NULL
  ,DAY_OF_MON       SMALLINT    NOT NULL
  ,DAY_OF_WEEK      VARCHAR(9)  NOT NULL
  ,WEEK_OF_YEAR     SMALLINT    NOT NULL
  ,DAY_OF_YEAR      SMALLINT    NOT NULL
)
AS
  WITH CTE_MY_DATE AS (
    SELECT DATEADD(DAY, SEQ4(), '2000-01-01') AS MY_DATE
      FROM TABLE(GENERATOR(ROWCOUNT=>10000))  -- Number of days after reference date in previous line
  )
  SELECT MY_DATE
        ,YEAR(MY_DATE)
        ,MONTH(MY_DATE)
        ,MONTHNAME(MY_DATE)
        ,DAY(MY_DATE)
        ,DAYOFWEEK(MY_DATE)
        ,WEEKOFYEAR(MY_DATE)
        ,DAYOFYEAR(MY_DATE)
    FROM CTE_MY_DATE
;


CREATE OR REPLACE TABLE dim_subscription (
   subscription_id number,
   ordinal_subscription_number number,
   subscription_start_ts timestamp_ntz,
   paid_start_ts timestamp_ntz,
   trial_start_ts timestamp_ntz,
   has_had_trial boolean,
   marketing_external_link_id number,
   constraint pk primary key(subscription_id)
);

CREATE OR REPLACE TABLE subscription_billing_cycles (
  billing_cycle_id number,
  user_id number,
  subscription_id number,
  sku_code text,
  marketing_external_link_id number,
   billing_cycle_start_ts timestamp_ntz,
   billing_cycle_expire_ts timestamp_ntz,
   grace_period_expire_ts timestamp_ntz,
   billing_cycle_length_days number,
   ordinal_billing_cycle_number number,
   subscription_type  text,
   payment_type text,
   amount_paid number(15,2),
   country_code text,
   is_signup boolean,
   is_trial_to_paid_conversion boolean,
   is_reconnect boolean,
   is_cancel boolean,
   constraint pk primary key (billing_cycle_id ),
  CONSTRAINT FK_subscription_billing_cycles_dim_subscription
    FOREIGN KEY (subscription_id)
      REFERENCES dim_subscription(subscription_id),
  CONSTRAINT FK_subscription_billing_cycles_dim_product
    FOREIGN KEY (sku_code)
      REFERENCES dim_product(sku_code),
  CONSTRAINT FK_subscription_billing_cycles_dim_user
    FOREIGN KEY (user_id)
      REFERENCES dim_user(user_id),
  CONSTRAINT FK_subscription_billing_cycles_dim_marketing_channel
    FOREIGN KEY (marketing_external_link_id)
      REFERENCES dim_marketing_channel(marketing_channel_id)
);

CREATE OR REPLACE TABLE subscription_events (
   subscription_event_id  number,
   subscription_event_type text,
   subscription_event_ts timestamp_ntz,
   billing_cycle_id number,
   user_id number,
   subscription_id number,
   sku_code text,
   marketing_external_link_id number,
   billing_cycle_start_ts timestamp_ntz,
   billing_cycle_expire_ts timestamp_ntz,
   grace_period_expire_ts timestamp_ntz,
   ordinal_billing_cycle_number number,
   subscription_type text,
   country_code text,
   constraint pk primary key(subscription_event_id),
  CONSTRAINT FK_subscription_events_subscription_billing_cycles
    FOREIGN KEY (billing_cycle_id)
      REFERENCES subscription_billing_cycles(billing_cycle_id)
);

CREATE OR REPLACE TABLE subscription_balance (
   balance_key number,
   reporting_dt timestamp_ntz,
   billing_cycle_id number,
   user_id number,
   subscription_id number,
   sku_code text,
   marketing_external_link_id number,
   subscription_status text,
   subscription_type text,
   country_code text,
   is_signup boolean,
   is_trial_to_paid_conversion boolean,
   is_cancel boolean,
   is_in_grace_period boolean,
   constraint pk primary key(balance_key),
  CONSTRAINT FK_subscription_balance_subscription_billing_cycles
    FOREIGN KEY (billing_cycle_id)
      REFERENCES subscription_billing_cycles(billing_cycle_id)
);




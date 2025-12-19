-- create schema test02;
--
-- set search_path to test02;

CREATE TABLE customer (
                          customer_id SERIAL PRIMARY KEY,
                          full_name VARCHAR(100),
                          email VARCHAR(100),
                          phone VARCHAR(15)
);

CREATE TABLE orders (
                        order_id SERIAL PRIMARY KEY,
                        customer_id INT REFERENCES customer(customer_id),
                        total_amount DECIMAL(10,2),
                        order_date DATE
);

INSERT INTO customer (full_name, email, phone) VALUES
                                                   ('Nguyen Van A', 'vana@example.com', '0901234567'),
                                                   ('Tran Thi B', 'thib@example.com', '0909876543'),
                                                   ('Le Van C', 'vanc@gmail.com', '0912345678');

INSERT INTO orders (customer_id, total_amount, order_date) VALUES
                                                               (1, 150.00, '2023-10-01'),
                                                               (1, 200.50, '2023-10-15'),
                                                               (2, 500.00, '2023-11-05'),
                                                               (3, 120.00, '2023-11-20'),
                                                               (2, 300.00, '2023-12-01');

CREATE OR REPLACE VIEW v_order_summary AS
SELECT
    c.full_name,
    o.total_amount,
    o.order_date,
    o.order_id
FROM orders o
         JOIN customer c ON o.customer_id = c.customer_id;

SELECT * FROM v_order_summary;

UPDATE v_order_summary
SET total_amount = 999.99
WHERE order_id = 1;

SELECT * FROM orders WHERE order_id = 1;

CREATE OR REPLACE VIEW v_monthly_sales AS
SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS month_year,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month_year;

SELECT * FROM v_monthly_sales;

DROP VIEW v_order_summary;


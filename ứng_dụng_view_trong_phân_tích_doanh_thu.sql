-- create schema test04;
-- set search_path to test04;
CREATE TABLE customer (
                          customer_id SERIAL PRIMARY KEY,
                          full_name VARCHAR(100),
                          region VARCHAR(50)
);

CREATE TABLE orders (
                        order_id SERIAL PRIMARY KEY,
                        customer_id INT REFERENCES customer(customer_id),
                        total_amount DECIMAL(10,2),
                        order_date DATE,
                        status VARCHAR(20)
);

CREATE TABLE product (
                         product_id SERIAL PRIMARY KEY,
                         name VARCHAR(100),
                         price DECIMAL(10,2),
                         category VARCHAR(50)
);

CREATE TABLE order_detail (
                              order_id INT REFERENCES orders(order_id),
                              product_id INT REFERENCES product(product_id),
                              quantity INT
);

INSERT INTO customer (full_name, region) VALUES
                                             ('User A', 'Hanoi'), ('User B', 'Hanoi'),
                                             ('User C', 'Danang'), ('User D', 'Danang'),
                                             ('User E', 'Saigon'), ('User F', 'Saigon'), ('User G', 'Saigon');

INSERT INTO orders (customer_id, total_amount, order_date, status) VALUES
                                                                       (1, 1000.00, '2023-10-01', 'Completed'),
                                                                       (2, 500.00, '2023-10-05', 'Pending'),
                                                                       (3, 2000.00, '2023-11-01', 'Shipped'),
                                                                       (4, 1500.00, '2023-11-10', 'Pending'),
                                                                       (5, 3000.00, '2023-12-01', 'Completed'),
                                                                       (6, 4000.00, '2023-12-05', 'Pending'),
                                                                       (7, 100.00, '2023-12-10', 'Pending');

CREATE OR REPLACE VIEW v_revenue_by_region AS
SELECT
    c.region,
    SUM(o.total_amount) AS total_revenue
FROM customer c
         JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region;

SELECT * FROM v_revenue_by_region
ORDER BY total_revenue DESC
LIMIT 3;

CREATE OR REPLACE VIEW v_pending_orders AS
SELECT
    order_id,
    customer_id,
    total_amount,
    status
FROM orders
WHERE status = 'Pending'
        WITH CHECK OPTION;

UPDATE v_pending_orders
SET total_amount = 9999.00
WHERE order_id = 2;

CREATE OR REPLACE VIEW v_revenue_above_avg AS
SELECT
    region,
    total_revenue
FROM v_revenue_by_region
WHERE total_revenue > (
    SELECT AVG(total_revenue) FROM v_revenue_by_region
);

SELECT * FROM v_revenue_above_avg;


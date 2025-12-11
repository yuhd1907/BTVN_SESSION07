CREATE DATABASE BookStore;
CREATE SCHEMA books;

SET SEARCH_PATH TO books;

CREATE TABLE Book
(
    book_id     serial primary key,
    title       varchar(225),
    author      varchar(100),
    genre       varchar(50),
    price       decimal(10, 2),
    description text,
    created_at  timestamp default current_timestamp
);

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_gin_author ON book USING GIN (author gin_trgm_ops);

CREATE INDEX idx_btree_genre ON book (genre);

EXPLAIN ANALYZE SELECT * FROM book WHERE author ILIKE '%Rowling%';
-- Seq Scan on book  (cost=0.00..11.12 rows=1 width=864) (actual time=0.031..0.031 rows=0.00 loops=1)
--   Filter: ((author)::text ~~* '%Rowling%'::text)
-- Planning:
--   Buffers: shared hit=48 read=2
-- Planning Time: 2.155 ms
-- Execution Time: 0.071 ms
EXPLAIN ANALYZE SELECT * FROM book WHERE genre = 'Fantasy';
-- Index Scan using idx_btree_genre on book  (cost=0.14..8.16 rows=1 width=864) (actual time=0.019..0.020 rows=0.00 loops=1)
--   Index Cond: ((genre)::text = 'Fantasy'::text)
--   Index Searches: 1
--   Buffers: shared hit=2
-- Planning:
--   Buffers: shared hit=11
-- Planning Time: 0.191 ms
-- Execution Time: 0.049 ms
CREATE INDEX idx_gin_title ON book USING GIN (title gin_trgm_ops);
CREATE INDEX idx_gin_description ON book USING GIN (description gin_trgm_ops);
CLUSTER book USING idx_btree_genre;
EXPLAIN ANALYZE SELECT * FROM book WHERE genre = 'Fantasy';
-- Seq Scan on book  (cost=0.00..0.00 rows=1 width=864) (actual time=0.010..0.010 rows=0.00 loops=1)
--   Filter: ((genre)::text = 'Fantasy'::text)
-- Planning:
--   Buffers: shared hit=47 read=2 dirtied=3
-- Planning Time: 14.188 ms
-- Execution Time: 0.022 ms


-- B-tree là loại chỉ mục hiệu quả nhất cho loại truy vấn sử dụng toán tử so sánh và sắp xếp.
-- GIN/GIST hiệu quả cho các truy vấn tìm kiếm substring hoặc tìm kiếm ilike
-- Hash index không được khuyến khích trong PostgreSQL khi làm việc trong hệ thống phải sử dụng các truy vấn so sánh và yêu cầu an toàn giao dịch.


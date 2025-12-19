-- create schema test03;
-- set search_path to test03;
--
CREATE TABLE post (
                      post_id SERIAL PRIMARY KEY,
                      user_id INT NOT NULL,
                      content TEXT,
                      tags TEXT[],
                      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                      is_public BOOLEAN DEFAULT TRUE
);

CREATE TABLE post_like (
                           user_id INT NOT NULL,
                           post_id INT NOT NULL,
                           liked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                           PRIMARY KEY (user_id, post_id)
);

INSERT INTO post (user_id, content, tags, created_at, is_public)
SELECT
    (random() * 1000)::INT,
    'Post content ' || md5(random()::text) || ' keyword',
    CASE
        WHEN i % 3 = 0 THEN ARRAY['travel', 'lifestyle']
        WHEN i % 3 = 1 THEN ARRAY['tech', 'coding']
        ELSE ARRAY['food', 'music']
        END,
    NOW() - (random() * interval '30 days'),
    CASE WHEN i % 5 = 0 THEN FALSE ELSE TRUE END
FROM generate_series(1, 200000) AS i;

EXPLAIN ANALYZE SELECT * FROM post WHERE LOWER(content) = 'post content keyword';

CREATE INDEX idx_post_lower_content ON post(LOWER(content));

EXPLAIN ANALYZE SELECT * FROM post WHERE LOWER(content) = 'post content keyword';

EXPLAIN ANALYZE SELECT * FROM post WHERE tags @> ARRAY['travel'];

CREATE INDEX idx_post_tags_gin ON post USING GIN(tags);

EXPLAIN ANALYZE SELECT * FROM post WHERE tags @> ARRAY['travel'];

EXPLAIN ANALYZE
SELECT * FROM post
WHERE is_public = TRUE AND created_at >= NOW() - INTERVAL '7 days';

CREATE INDEX idx_post_recent_public
    ON post(created_at DESC)
    WHERE is_public = TRUE;

EXPLAIN ANALYZE
SELECT * FROM post
WHERE is_public = TRUE AND created_at >= NOW() - INTERVAL '7 days';

EXPLAIN ANALYZE SELECT * FROM post WHERE user_id = 100 ORDER BY created_at DESC;

CREATE INDEX idx_post_user_timeline ON post(user_id, created_at DESC);

EXPLAIN ANALYZE SELECT * FROM post WHERE user_id = 100 ORDER BY created_at DESC;


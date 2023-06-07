-- Analisa Sentimen Pengguna Dalam Mengakses Konten atau Video Melalui Platform Youtube

-- Data Cleaning (Menemukan dan menghapus missing values, menemukan dan menghapus data duplikat)
-- Menemukan missing values
--Tabel Comments
SELECT *
FROM comments
WHERE videoID IS NULL OR Comment IS NULL OR Likes IS NULL OR Sentiment IS NULL;

-- Tabel Video_stats
SELECT *
FROM videos_stats
WHERE Title IS NULL OR videoID IS NULL OR PublishedAt IS NULL OR Keyword IS NULL OR Likes IS NULL OR Comments IS NULL OR Views IS NULL;

-- Menghapus missing values
-- Tabel Comments
DELETE FROM comments
WHERE videoID IS NULL OR Comment IS NULL OR Likes IS NULL OR Sentiment IS NULL;

-- Tabel Video_stats
DELETE FROM videos_stats
WHERE Title IS NULL OR videoID IS NULL OR PublishedAt IS NULL OR Keyword IS NULL OR Likes IS NULL OR Comments IS NULL OR Views IS NULL;

-- Menemukan data duplikat
-- Tabel Comments
SELECT videoID, Comment, Likes, Sentiment, COUNT(*) AS jumlah_duplikat
FROM comments
GROUP BY videoID, Comment, Likes, Sentiment
HAVING COUNT(*) > 1;

-- Tabel Video_stats
SELECT Title, videoID, PublishedAt, Keyword, Likes, Comments, Views, COUNT(*) AS jumlah_duplikat
FROM videos_stats
GROUP BY Title, videoID, PublishedAt, Keyword, Likes, Comments, Views
HAVING COUNT(*) > 1;

-- Menghapus data duplikat
-- Tidak ditemukan data duplikat pada tabel videos_stats, maka hanya membuat kueri untuk menghapus pada tabel comments saja
-- Tabel Comments
DELETE FROM comments
WHERE (videoID, Comment, Likes, Sentiment) NOT IN (
    SELECT videoID, Comment, Likes, Sentiment
    FROM (
        SELECT videoID, Comment, Likes, Sentiment, ROW_NUMBER() OVER (PARTITION BY videoID, Comment, Likes, Sentiment ORDER BY videoID) AS rn
        FROM comments
    ) tmp
    WHERE rn = 1
);
SELECT * FROM comments

-- Q1: Video apa yang paling banyak dikomentari? Atau yang paling disukai?
-- Video yang paling banyak dikomentari
SELECT videoID, COUNT(*) AS total_comments
FROM comments
GROUP BY videoID
ORDER BY total_comments DESC
LIMIT 1;

-- Video yang paling disukai
SELECT videoID, Likes
FROM videos_stats
ORDER BY Likes DESC
LIMIT 1;

-- Q2: Berapa banyak total penayangan yang dimiliki setiap kategori? Berapa banyak yang menyukai?
-- Total penayangan dan jumlah likes per kategori
SELECT Keyword, SUM(Views) AS total_views, SUM(Likes) AS total_likes
FROM videos_stats
GROUP BY Keyword;

-- Q3: Apa komentar yang paling disukai?
SELECT Comment, Likes
FROM comments
ORDER BY Likes DESC
LIMIT 1;

-- Q4: Berapa rasio penayangan/likes per video? Per setiap kategori?
-- Rasio penayangan/suka per video
SELECT videoID, (Views / Likes) AS ratio
FROM videos_stats;

-- Rasio penayangan/suka per kategori
SELECT Keyword, AVG(Views / Likes) AS ratio
FROM videos_stats
GROUP BY Keyword;

-- Q5: Berapa rata-rata jumlah komentar per video?
SELECT AVG(Comments) AS rata_rata_komentar_per_video
FROM videos_stats;

-- Q6: Apa video dengan jumlah penayangan tertinggi?
SELECT Title, Views
FROM videos_stats
ORDER BY Views DESC
LIMIT 1;

-- Q7: Berapa jumlah total komentar yang diterima video-video dengan jumlah penayangan di atas rata-rata?
SELECT SUM(Comments) AS total_komentar_diatas_rata_rata
FROM videos_stats
WHERE Views > (
    SELECT AVG(Views)
    FROM videos_stats
);

-- Q8: Apa video dengan rasio penayangan/suka terendah?
SELECT Title, (Views / Likes) AS ratio
FROM videos_stats
ORDER BY ratio ASC
LIMIT 1;

-- Q9: Apa komentar dengan sentimen positif dan negatif tertinggi?
SELECT Comment, Sentiment
FROM comments
WHERE Sentiment < 1
ORDER BY Likes DESC
LIMIT 1;

-- Positif sentimen
SELECT Comment, Sentiment
FROM comments
WHERE Sentiment >= 1
ORDER BY Likes DESC
LIMIT 1;

-- Q10: Berapa rata-rata jumlah suka per komentar?
SELECT AVG(Likes) AS rata_rata_likes_per_komentar
FROM comments;

-- Q11: Berapa skor sentimen rata-rata di setiap kategori (Keyword)?
SELECT vs.Keyword, AVG(c.Sentiment) AS rata_rata_sentimen
FROM videos_stats vs
JOIN comments c ON vs.videoID = c.videoID
GROUP BY vs.Keyword;

-- Q12: Berapa kali nama perusahaan (misal, Apple atau Samsung) muncul di setiap kategori (Keyword)?
SELECT vs.Keyword, COUNT(*) AS jumlah_kemunculan
FROM videos_stats vs
JOIN comments c ON vs.videoID = c.videoID
WHERE c.Comment LIKE '%Apple%' OR c.Comment LIKE '%Samsung%'
GROUP BY vs.Keyword;



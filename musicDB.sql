-- Music Review System
CREATE DATABASE IF NOT EXISTS musicReview;

USE musicReview;

-- Drops tables
DROP TABLE IF EXISTS songInstruments;
DROP TABLE IF EXISTS artistInstruments;
DROP TABLE IF EXISTS instruments;
DROP TABLE IF EXISTS songReview;
DROP TABLE IF EXISTS albumReview;
DROP TABLE IF EXISTS artistReview;
DROP TABLE IF EXISTS reviewerUser;
DROP TABLE IF EXISTS artistGenres;
DROP TABLE IF EXISTS albumGenres;
DROP TABLE IF EXISTS songGenres;
DROP TABLE IF EXISTS producerAlbums;
DROP TABLE IF EXISTS producerSongs;
DROP TABLE IF EXISTS artistsAlbums;
DROP TABLE IF EXISTS artistsSongs;
DROP TABLE IF EXISTS song;
DROP TABLE IF EXISTS album;
DROP TABLE IF EXISTS genre;
DROP TABLE IF EXISTS artist;
DROP TABLE IF EXISTS producer;

-- Producer
CREATE TABLE producer(
	producer_id INT AUTO_INCREMENT PRIMARY KEY,
    producerName VARCHAR(64),
    foundedDate DATE
);

-- Artist
CREATE TABLE artist(
	artist_id INT AUTO_INCREMENT PRIMARY KEY,
    producer_id INT,
    artistName VARCHAR(64),
    numMembers INT,
    CONSTRAINT artist_producer_fk FOREIGN KEY (producer_id) REFERENCES producer(producer_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Genre
CREATE TABLE genre(
	genreName VARCHAR(64) PRIMARY KEY,
    description VARCHAR(256)
);


-- Album
CREATE TABLE album(
	album_id INT AUTO_INCREMENT PRIMARY KEY,
    albumName VARCHAR(64),
    releaseDate DATE,
    numberSold INT,
    artist_id INT,
    producer_id INT,
    CONSTRAINT album_producer_fk FOREIGN KEY (producer_id) REFERENCES producer(producer_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT album_artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE
);



-- Song
CREATE TABLE song(
	song_id INT AUTO_INCREMENT PRIMARY KEY,
    songName VARCHAR(64),
    producer_id INT,
    dateReleased DATE,
    songLength INT,
    album_id INT,
    CONSTRAINT song_album_fk FOREIGN KEY (album_id) REFERENCES album(album_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT song_producer_fk FOREIGN KEY (producer_id) REFERENCES producer(producer_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Artist -> song
CREATE TABLE artistsSongs(
	artist_id INT,
    song_id INT,
    CONSTRAINT artistsSongs_artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT artistsSongs_song_fk FOREIGN KEY (song_id) REFERENCES song(song_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Artist -> album
CREATE TABLE artistsAlbums(
	artist_id INT,
    album_id INT,
    CONSTRAINT artistsAlbums_artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT artistsAlbums_album_fk FOREIGN KEY (album_id) REFERENCES album(album_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Producer -> song
CREATE TABLE producerSongs(
	producer_id INT,
    song_id INT,
    CONSTRAINT producerSongs_producer_fk FOREIGN KEY (producer_id) REFERENCES producer(producer_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT producerSongs_song_fk FOREIGN KEY (song_id) REFERENCES song(song_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Producer -> album
CREATE TABLE producerAlbums(
	producer_id INT,
    album_id INT,
    CONSTRAINT producerAlbums_producer_fk FOREIGN KEY (producer_id) REFERENCES producer(producer_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT producerAlbums_album_fk FOREIGN KEY (album_id) REFERENCES album(album_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Genre -> *
CREATE TABLE songGenres(
	song_id INT,
    genre VARCHAR(64),
    CONSTRAINT songGenres_song_fk FOREIGN KEY (song_id) REFERENCES song(song_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT songGenres_genre_fk FOREIGN KEY (genre) REFERENCES genre(genreName) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE albumGenres(
	album_id INT,
    genre VARCHAR(64),
    CONSTRAINT albumGenres_album_fk FOREIGN KEY (album_id) REFERENCES album(album_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT albumGenres_genre_fk FOREIGN KEY (genre) REFERENCES genre(genreName) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE artistGenres(
	artist_id INT,
    genre VARCHAR(64),
    CONSTRAINT artistGenres_artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT artistGenres_genre_fk FOREIGN KEY (genre) REFERENCES genre(genreName) ON DELETE SET NULL ON UPDATE CASCADE
);


CREATE TABLE reviewerUser(
	username VARCHAR(64) PRIMARY KEY,
    userPassword VARCHAR(64),
    email VARCHAR(64),
    dateJoined DATE,
	name VARCHAR(80)
);


-- Reviews
CREATE TABLE artistReview(
	reviewId INT AUTO_INCREMENT PRIMARY KEY,
    stars DOUBLE NOT NULL CHECK(stars BETWEEN 0.0 AND 5.0),
    reviewDescription VARCHAR(256),
    reviewer VARCHAR(64),
    reviewDate DATE NOT NULL,
    artist_id INT,
    CONSTRAINT artistReview_reviewer_fk FOREIGN KEY (reviewer) REFERENCES reviewerUser(username) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT artistReview_artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE albumReview(
	reviewId INT AUTO_INCREMENT PRIMARY KEY,
    stars DOUBLE NOT NULL CHECK(stars BETWEEN 0.0 AND 5.0),
    reviewDescription VARCHAR(256),
    reviewer VARCHAR(64),
    reviewDate DATE NOT NULL,
    album_id INT,
    CONSTRAINT albumReview_reviewer_fk FOREIGN KEY (reviewer) REFERENCES reviewerUser(username) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT albumReview_album_fk FOREIGN KEY (album_id) REFERENCES album(album_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE songReview(
	reviewId INT AUTO_INCREMENT PRIMARY KEY,
    stars DOUBLE NOT NULL CHECK(stars BETWEEN 0.0 AND 5.0),
    reviewDescription VARCHAR(256),
    reviewer VARCHAR(64),
    reviewDate DATE NOT NULL,
    song_id INT,
    CONSTRAINT songReview_reviewer_fk FOREIGN KEY (reviewer) REFERENCES reviewerUser(username) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT songReview_song_fk FOREIGN KEY (song_id) REFERENCES song(song_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Instruments
CREATE TABLE instruments(
	instrumentName VARCHAR(64) PRIMARY KEY,
    instrumentDescription VARCHAR(256)
);

-- Artist -> instruments
CREATE TABLE artistInstruments(
	artist_id INT,
    instrumentName VARCHAR(64),
    CONSTRAINT artistInstruments_artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT artistInstruments_instrument_fk FOREIGN KEY (instrumentName) REFERENCES instruments(instrumentName) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Song -> instruments
CREATE TABLE songInstruments(
	song_id INT,
    instrumentName VARCHAR(64),
    CONSTRAINT songInstruments_song_fk FOREIGN KEY (song_id) REFERENCES song(song_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT songInstruments_instrument_fk FOREIGN KEY (instrumentName) REFERENCES instruments(instrumentName) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Gets the average star rating for a song
DROP FUNCTION IF EXISTS avgSongRating;
DELIMITER $$
CREATE FUNCTION avgSongRating(songID INT)
  RETURNS DOUBLE
  DETERMINISTIC
  READS SQL DATA
  BEGIN
  DECLARE ret_val DOUBLE;
  SELECT AVG(stars) INTO ret_val FROM songReview WHERE songReview.song_id = songID;
  RETURN ret_val;
  END$$

DELIMITER ;

-- Gets the average star rating for an album
DROP FUNCTION IF EXISTS avgAlbumRating;
DELIMITER $$
CREATE FUNCTION avgAlbumRating(albumID INT)
  RETURNS DOUBLE
  DETERMINISTIC
  READS SQL DATA
  BEGIN
  DECLARE ret_val DOUBLE;
  SELECT AVG(stars) INTO ret_val FROM albumReview WHERE albumReview.album_id = albumID;
  RETURN ret_val;
  END$$

DELIMITER ;

-- Gets the average star rating for an artist
DROP FUNCTION IF EXISTS avgArtistRating;
DELIMITER $$
CREATE FUNCTION avgArtistRating(artistID INT)
  RETURNS DOUBLE
  DETERMINISTIC
  READS SQL DATA
  BEGIN
  DECLARE ret_val DOUBLE;
  SELECT AVG(stars) INTO ret_val FROM artistReview WHERE artistReview.artist_id = artistID;
  RETURN ret_val;
  END$$

DELIMITER ;

-- GENRE JOINS

-- joins a song with song's genre
DROP PROCEDURE IF EXISTS songJoinGenre;
DELIMITER $$
CREATE PROCEDURE songJoinGenre(IN song_id INT)
	BEGIN
	SELECT * FROM song LEFT JOIN songgenres
	ON song.song_id = songgenres.song_id;
	END $$
DELIMITER ;

-- joins an artist with song's genre
DROP PROCEDURE IF EXISTS artistJoinGenre;
DELIMITER $$
CREATE PROCEDURE artistJoinGenre(IN artist_id INT)
	BEGIN
	SELECT * FROM artist LEFT JOIN artistgenres
	ON artist.artist_id = artistgenre.artist_id;
	END $$
DELIMITER ;

-- joins an album with song's genre
DROP PROCEDURE IF EXISTS albumJoinGenre;
DELIMITER $$
CREATE PROCEDURE albumJoinGenre(IN album_id INT)
	BEGIN
	SELECT * FROM album LEFT JOIN albumgenres
	ON album.album_id = albumgenre.album_id;
	END $$
DELIMITER ;

-- INSTRUMENT JOINS

-- joins a song with the song's instruments
DROP PROCEDURE IF EXISTS songJoinInstruments;
DELIMITER $$
CREATE PROCEDURE songJoinInstruments(IN song_id INT)
	BEGIN
	SELECT * FROM song LEFT JOIN songinstruments
	ON song.song_id = songinstruments.song_id;
	END $$
DELIMITER ;

-- joins an artist with the artist's instruments
DROP PROCEDURE IF EXISTS artistJoinInstruments;
DELIMITER $$
CREATE PROCEDURE artistJoinInstruments(IN artist_id INT)
	BEGIN
	SELECT * FROM artist LEFT JOIN artistinstruments
	ON artist.artist_id = artistinstruments.artist_id;
	END $$
DELIMITER ;

-- REVIEW JOINS

-- joins a song review with the song it is reviewing
DROP PROCEDURE IF EXISTS songJoinReview;
DELIMITER $$
CREATE PROCEDURE songJoinReview(IN reviewID INT)
	BEGIN
	SELECT * FROM song LEFT JOIN songreview
	ON song.song_id = songreview.song_id;
	END $$
DELIMITER ;

-- joins an album review with the album it is reviewing
DROP PROCEDURE IF EXISTS albumJoinReview;
DELIMITER $$
CREATE PROCEDURE albumJoinReview(IN reviewID INT)
	BEGIN
	SELECT * FROM album LEFT JOIN albumreview
	ON album.album_id = albumreview.album_id;
	END $$
DELIMITER ;

-- joins an artist review with the artist it is reviewing
DROP PROCEDURE IF EXISTS artistJoinReview;
DELIMITER $$
CREATE PROCEDURE artistJoinReview(IN reviewID INT)
	BEGIN
	SELECT * FROM artist LEFT JOIN artistreview
	ON artist.artist_id = artistreview.artist_id;
	END $$
DELIMITER ;

-- DELETING REVIEWS
-- Delete a song review
DROP PROCEDURE IF EXISTS deleteSongReview;
DELIMITER $$
CREATE PROCEDURE deleteSongReview( IN reviewID INT)
	BEGIN
	DELETE FROM songreview
	WHERE reviewID = songreview.reviewID;
	END $$
DELIMITER ;

-- Delete an artist review
DROP PROCEDURE IF EXISTS deleteArtistReview;
DELIMITER $$
CREATE PROCEDURE deleteArtistReview( IN reviewID INT)
	BEGIN
	DELETE FROM artistreview
	WHERE reviewID = artistreview.reviewID;
	END $$
DELIMITER ;

-- Delete an album review
DROP PROCEDURE IF EXISTS deleteAlbumReview;
DELIMITER $$
CREATE PROCEDURE deleteAlbumReview( IN reviewID INT)
	BEGIN
	DELETE FROM albumreview
	WHERE reviewID = album.reviewID;
	END $$
DELIMITER ;

-- DELETING ACCOUNTS



-- Delete a review user account
DROP PROCEDURE IF EXISTS deleteReviewerUser;
DELIMITER $$
CREATE PROCEDURE deleteReviewerUser( IN username INT)
	BEGIN
	DELETE FROM revieweruser
	WHERE username = revieweruser.username;
	END $$
DELIMITER ;



-- Creating a Song Review

DELIMITER ;
DROP PROCEDURE IF EXISTS createSongReview;
DELIMITER $$
CREATE PROCEDURE createSongReview(stars_p DOUBLE, reviewer_p VARCHAR(64),
	reviewDescription_p VARCHAR(256),
	reviewDate date, songName_p VARCHAR(64))
	BEGIN
		DECLARE reviewIdVal INT;
		DECLARE songIdVal INT;
		SELECT 
    MAX(reviewId) + 1
INTO reviewIdVal FROM
    songreview;
		IF reviewIdVal IS NULL THEN SET reviewIdVal = 1;
		END IF;
		SELECT 
    song_id
INTO songIdVal FROM
    song
WHERE
    song.songName = songName_p;
		INSERT INTO songreview(reviewId, stars, reviewDescription, reviewer, reviewDate, song_id)
			VALUES (reviewIdVal, stars_p,
				reviewDescription_p, reviewer_p,
				reviewDate, songIdVal);
	END $$
DELIMITER ;

-- Creating an Artist Review

DELIMITER ;
DROP PROCEDURE IF EXISTS createArtistReview;
DELIMITER $$
CREATE PROCEDURE createArtistReview(stars_p DOUBLE, reviewer_p VARCHAR(64),
reviewDescription_p VARCHAR(256),
reviewDate date, artistName_p VARCHAR(64))
BEGIN
DECLARE reviewIdVal INT;
DECLARE artistIdVal INT;
SELECT 
    MAX(reviewId) + 1
INTO reviewIdVal FROM
    artistreview;
IF reviewIdVal IS NULL THEN SET reviewIdVal = 1;
END IF;
SELECT 
    artist_id
INTO artistIdVal FROM
    artist
WHERE
    artist.ArtistName = artistName_p;
INSERT INTO artistreview(reviewId, stars, reviewDescription, reviewer, reviewDate, artist_id)
VALUES (reviewIdVal, stars_p,
reviewDescription_p, reviewer_p,
reviewDate, artistIdVal);
END $$
DELIMITER ;

-- Creating an Album Review

DELIMITER ;
DROP PROCEDURE IF EXISTS createAlbumReview;
DELIMITER $$
CREATE PROCEDURE createAlbumReview(stars_p DOUBLE, reviewer_p VARCHAR(64),
reviewDescription_p VARCHAR(256),
reviewDate date, albumName_p VARCHAR(64))
BEGIN
DECLARE reviewIdVal INT;
DECLARE albumIdVal INT;
SELECT 
    MAX(reviewId) + 1
INTO reviewIdVal FROM
    albumreview;
IF reviewIdVal IS NULL THEN SET reviewIdVal = 1;
END IF;
SELECT 
    album_id
INTO albumIdVal FROM
    album
WHERE
    album.AlbumName = albumName_p;
INSERT INTO albumreview(reviewId, stars, reviewDescription, reviewer, reviewDate, album_id)
VALUES (reviewIdVal, stars_p,
reviewDescription_p, reviewer_p,
reviewDate, albumIdVal);
END $$
DELIMITER ;


-- Dummy Data


-- REVIEWER USERS Data
INSERT INTO revieweruser(username, userPassword, email, dateJoined, name)
VALUES ("Maggie", "Password", "maggieclark2001@gmail.com", "2019-08-11", "Maggie");

INSERT INTO revieweruser(username, userPassword, email, dateJoined, name)
VALUES ("Luke", "Password", "luke@gmail.com", "2019-07-11", "Luke");

INSERT INTO revieweruser(username, userPassword, email, dateJoined, name)
VALUES ("Jake", "Password", "jake@gmail.com", "2018-08-11", "Jake");

-- GENRE DATA
INSERT INTO genre(genreName, description) VALUES ("Pre-K", "Music for children");
INSERT INTO genre(genreName, description) VALUES ("Country", "Country music");
INSERT INTO genre(genreName, description) VALUES ("Classical", "Classical music");

-- PRODUCER DATA
INSERT INTO producer(producer_id, producerName, foundedDate) VALUES
(1, "Producer1", "2020-08-11");
INSERT INTO producer(producer_id, producerName, foundedDate) VALUES
(2, "Producer2", "1236-06-11");



-- Instrument Data
INSERT INTO instruments(instrumentName, instrumentDescription) VALUES ("Guitar", "A guitar");
INSERT INTO instruments(instrumentName, instrumentDescription) VALUES ("Classical band", "Violin, Cello, Flute, Clarinet");

-- ARTIST DATA
INSERT INTO artist(artist_id, producer_id, artistName, numMembers) VALUES
(1, 1, "Spider", 1);
INSERT INTO artist(artist_id, producer_id, artistName, numMembers) VALUES
(2, 1, "Johnny Cash", 1);
INSERT INTO artist(artist_id, producer_id, artistName, numMembers) VALUES
(3, 1, "Mozart", 1);

-- artist genres
INSERT INTO artistgenres(artist_id, genre) VALUES (1, "Pre-K");
INSERT INTO artistgenres(artist_id, genre) VALUES (2, "Country");
INSERT INTO artistgenres(artist_id, genre) VALUES (3, "Classical");

-- artist instruments
INSERT INTO artistinstruments(artist_id, instrumentName) VALUES (1, NULL);
INSERT INTO artistinstruments(artist_id, instrumentName) VALUES (2, "Guitar");
INSERT INTO artistinstruments(artist_id, instrumentName) VALUES (3, "Classical band");

-- artist review
CALL createArtistReview(5, "Maggie", "Example review", "2021-08-12", "Spider");
CALL createAlbumReview(4, "Luke", "Example review", "2021-10-11", "Johnny Cash");
CALL createAlbumReview(3, "Jake", "Example review", "2021-11-11", "Mozart");



-- ALBUMS DATA
INSERT INTO album(album_id, albumname, releasedate, numberSold, artist_id, producer_id)
VALUES (1, "Itsy Bitsy Spider Hits", "2021-08-08", 50000, 1, 1);
INSERT INTO album(album_id, albumname, releasedate, numberSold, artist_id, producer_id)
VALUES (2, "Johnny Cash Hits", "2021-08-05", 70000, 2, 1);
INSERT INTO album(album_id, albumname, releasedate, numberSold, artist_id, producer_id)
VALUES (3, "Mozart Hits", "2021-08-05", 100000, 3, 2);

-- SONGS DATA
INSERT INTO song(song_id, songName, producer_id, dateReleased, songLength, album_id)
VALUES (1, "Itty Bitty Spider", 1, "2021-08-11", 3, 1);
INSERT INTO song(song_id, songName, producer_id, dateReleased, songLength, album_id)
VALUES (2, "Folsom Prison Blues", 1, "1960-08-11", 3, 2);
INSERT INTO song(song_id, songName, producer_id, dateReleased, songLength, album_id)
VALUES (3, "Ring of Fire", 1, "1963-08-11", 3, 2);
INSERT INTO song(song_id, songName, producer_id, dateReleased, songLength, album_id)
VALUES (4, "Ave Verum Corpus", 1, "1780-08-11", 6, 3);
INSERT INTO song(song_id, songName, producer_id, dateReleased, songLength, album_id)
VALUES (5, "Fantasia in D Minor, K. 397", 1, "1782-08-11", 7, 3);

-- artist albums
INSERT INTO artistsalbums(artist_id, album_id) VALUES (1, 1);
INSERT INTO artistsalbums(artist_id, album_id) VALUES (2, 2);
INSERT INTO artistsalbums(artist_id, album_id) VALUES (3, 3);

-- artist songs
INSERT INTO artistssongs(artist_id, song_id) VALUES (1, 1);
INSERT INTO artistssongs(artist_id, song_id) VALUES (2, 2);
INSERT INTO artistssongs(artist_id, song_id) VALUES (2, 3);
INSERT INTO artistssongs(artist_id, song_id) VALUES (3, 4);
INSERT INTO artistssongs(artist_id, song_id) VALUES (3, 5);


-- producer albums
INSERT INTO produceralbums(producer_id, album_id) VALUES (1, 1);
INSERT INTO produceralbums(producer_id, album_id) VALUES (1, 2);
INSERT INTO produceralbums(producer_id, album_id) VALUES (1, 3);

-- producer songs
INSERT INTO producersongs(producer_id, song_id) VALUES (1, 1);
INSERT INTO producersongs(producer_id, song_id) VALUES (1, 2);
INSERT INTO producersongs(producer_id, song_id) VALUES (1, 3);
INSERT INTO producersongs(producer_id, song_id) VALUES (1, 4);
INSERT INTO producersongs(producer_id, song_id) VALUES (1, 5);

-- album genres
INSERT INTO albumgenres(album_id, genre) VALUES (1, "Pre-K");
INSERT INTO albumgenres(album_id, genre) VALUES (2, "Country");
INSERT INTO albumgenres(album_id, genre) VALUES (3, "Classical");

-- album reviews
CALL createAlbumReview(5, "Maggie", "Example review", "2021-08-12", "Itsy Bitsy Spider Hits");
CALL createAlbumReview(4, "Luke", "Example review", "2021-10-11", "Johnny Cash Hits");
CALL createAlbumReview(3, "Jake", "Example review", "2021-11-11", "Mozart Hits");


-- songs genres
INSERT INTO songgenres(song_id, genre) VALUES (1, "Pre-K");
INSERT INTO songgenres(song_id, genre) VALUES (2, "Country");
INSERT INTO songgenres(song_id, genre) VALUES (3, "Country");
INSERT INTO songgenres(song_id, genre) VALUES (4, "Classical");
INSERT INTO songgenres(song_id, genre) VALUES (5, "Classical");

-- song instruments
INSERT INTO songinstruments(song_id, instrumentName) VALUES (2, "Guitar");
INSERT INTO songinstruments(song_id, instrumentName) VALUES (3, "Guitar");
INSERT INTO songinstruments(song_id, instrumentName) VALUES (4, "Classical Band");
INSERT INTO songinstruments(song_id, instrumentName) VALUES (5, "Classical Band");

-- song review
CALL createSongReview(5, "Maggie", "Example review", "2021-08-11", "Itty Bitty Spider");

CALL createSongReview(4, "Luke", "Example review", "2021-10-11", "Folsom Prison Blues");

CALL createSongReview(4, "Jake", "Example review", "2021-11-11", "Fantasia in D Minor, K. 397");










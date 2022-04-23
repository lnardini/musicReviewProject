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
DROP TABLE IF EXISTS artistUser;
DROP TABLE IF EXISTS reviewerUser;
DROP TABLE IF EXISTS adminUser;
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

-- Accounts
CREATE TABLE adminUser(
	username VARCHAR(64) PRIMARY KEY,
    userPassword VARCHAR(64),
    email VARCHAR(64)
);

CREATE TABLE reviewerUser(
	username VARCHAR(64) PRIMARY KEY,
    userPassword VARCHAR(64),
    email VARCHAR(64),
    dateJoined DATE,
	name VARCHAR(80)
);

CREATE TABLE artistUser(
	username VARCHAR(64) PRIMARY KEY,
    userPassword VARCHAR(64),
    email VARCHAR(64),
    artist_id INT,
    CONSTRAINT artistUser_artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE
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

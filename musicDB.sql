-- Music Review System 

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
    CONSTRAINT producer_fk FOREIGN KEY (producer_id) REFERENCES producer(producer_id) ON DELETE SET NULL ON UPDATE CASCADE
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
    CONSTRAINT producer_fk FOREIGN KEY (producer_id) REFERENCES producer(producer_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE
);



-- Song 
CREATE TABLE song(
	song_id INT AUTO_INCREMENT PRIMARY KEY,
    songName VARCHAR(64),
    producer_id INT,
    dateReleased DATE,
    songLength INT,
    album_id INT,
    CONSTRAINT album_fk FOREIGN KEY (album_id) REFERENCES album(album_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT producer_fk FOREIGN KEY (producer_id) REFERENCES producer(producer_id) ON DELETE SET NULL ON UPDATE CASCADE
);
    
-- Artist -> song
CREATE TABLE artistsSongs(
	artist_id INT,
    song_id INT,
    CONSTRAINT artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT song_fk FOREIGN KEY (song_id) REFERENCES song(song_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Artist -> album
CREATE TABLE artistsAlbums(
	artist_id INT,
    album_id INT,
    CONSTRAINT artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT album_fk FOREIGN KEY (album_id) REFERENCES album(album_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Producer -> song
CREATE TABLE producerSongs(
	producer_id INT,
    song_id INT,
    CONSTRAINT producer_fk FOREIGN KEY (producer_id) REFERENCES producer(producer_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT song_fk FOREIGN KEY (song_id) REFERENCES song(song_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Producer -> album
CREATE TABLE producerAlbums(
	producer_id INT,
    album_id INT,
    CONSTRAINT producer_fk FOREIGN KEY (producer_id) REFERENCES producer(producer_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT album_fk FOREIGN KEY (album_id) REFERENCES album(album_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Genre -> * 
CREATE TABLE songGenres(
	song_id INT,
    genre VARCHAR(64),
    CONSTRAINT song_fk FOREIGN KEY (song_id) REFERENCES song(song_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT genre_fk FOREIGN KEY (genre) REFERENCES genre(genreName) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE albumGenres(
	album_id INT,
    genre VARCHAR(64),
    CONSTRAINT album_fk FOREIGN KEY (album_id) REFERENCES album(album_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT genre_fk FOREIGN KEY (genre) REFERENCES genre(genreName) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE artistGenres(
	album_id INT,
    genre VARCHAR(64),
    CONSTRAINT artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT genre_fk FOREIGN KEY (genre) REFERENCES genre(genreName) ON DELETE SET NULL ON UPDATE CASCADE
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
    CONSTRAINT artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Reviews
CREATE TABLE artistReview(
	reviewId INT AUTO_INCREMENT PRIMARY KEY,
    stars DOUBLE NOT NULL CHECK(stars BETWEEN 0.0 AND 5.0),
    reviewDescription VARCHAR(256),
    reviewer VARCHAR(64),
    reviewDate DATE NOT NULL,
    artist_id INT,
    CONSTRAINT reviewer_fk FOREIGN KEY (reviewer) REFERENCES reviewUser(username) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE albumReview(
	reviewId INT AUTO_INCREMENT PRIMARY KEY,
    stars DOUBLE NOT NULL CHECK(stars BETWEEN 0.0 AND 5.0),
    reviewDescription VARCHAR(256),
    reviewer VARCHAR(64),
    reviewDate DATE NOT NULL,
    album_id INT,
    CONSTRAINT reviewer_fk FOREIGN KEY (reviewer) REFERENCES reviewUser(username) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT album_fk FOREIGN KEY (album_id) REFERENCES album(album_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE songReview(
	reviewId INT AUTO_INCREMENT PRIMARY KEY,
    stars DOUBLE NOT NULL CHECK(stars BETWEEN 0.0 AND 5.0),
    reviewDescription VARCHAR(256),
    reviewer VARCHAR(64),
    reviewDate DATE NOT NULL,
    song_id INT,
    CONSTRAINT reviewer_fk FOREIGN KEY (reviewer) REFERENCES reviewUser(username) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT song_fk FOREIGN KEY (song_id) REFERENCES song(song_id) ON DELETE SET NULL ON UPDATE CASCADE
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
    CONSTRAINT artist_fk FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT instrument_fk FOREIGN KEY (instrumentName) REFERENCES instrument(instrumentName) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Song -> instruments
CREATE TABLE artistInstruments(
	song_id INT,
    instrumentName VARCHAR(64),
    CONSTRAINT song_fk FOREIGN KEY (song_id) REFERENCES song(song_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT instrument_fk FOREIGN KEY (instrumentName) REFERENCES instrument(instrumentName) ON DELETE SET NULL ON UPDATE CASCADE
);










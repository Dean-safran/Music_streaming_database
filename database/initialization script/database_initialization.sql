DROP TABLE IF EXISTS History CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Downloaded CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Favorites CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS InPlayList CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS CanAccess CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS FriendOf CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Playlist CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS AppUsers CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS SubscriptionFee CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS ZipInfo CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS BelongsTo CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS SongGenre CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Genre CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Includes CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS AlbumArtist CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS AlbumSong CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Album CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Sings CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Song CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS MemberOf CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Company CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS Artist CASCADE CONSTRAINTS;

CREATE TABLE ZipInfo (
    zip VARCHAR(10) PRIMARY KEY,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL
);


CREATE Table SubscriptionFee (
    subscription_tier VARCHAR(100) PRIMARY KEY,
    monthly_fee DECIMAL(8, 2)
);


CREATE TABLE Artist (
    AID INTEGER PRIMARY KEY,
    artistName VARCHAR(100) NOT NULL,
    nationality VARCHAR(100)
);

CREATE TABLE MemberOf (
    AID_member INTEGER,
    AID_group_band INTEGER,
    PRIMARY KEY (AID_member, AID_group_band),
    FOREIGN KEY(AID_member) REFERENCES Artist(AID),
    FOREIGN KEY(AID_group_band) REFERENCES Artist(AID)
);

CREATE TABLE Song (
    SID INTEGER PRIMARY KEY,
    songName VARCHAR(200),
    length_ms INTEGER,
    releaseYear INTEGER,
    listens INT,
    link_to_source VARCHAR(200),
    popularity NUMBER

);


CREATE TABLE Sings (
    AID INTEGER,
    SID INTEGER,

    PRIMARY KEY (AID, SID),

    FOREIGN KEY (AID)
        REFERENCES Artist(AID),

    FOREIGN KEY (SID)
        REFERENCES Song(SID)
);


CREATE TABLE Company (
    CID INTEGER PRIMARY KEY,
    companyName VARCHAR(100) NOT NULL,
    zip VARCHAR(10),
    FOREIGN KEY(zip) REFERENCES ZipInfo (zip)
);


CREATE TABLE Album (
    albumName VARCHAR(100),
    releaseYear INTEGER,
    CID INTEGER,

    PRIMARY KEY (albumName, CID),

    FOREIGN KEY (CID)
        REFERENCES Company(CID)
);

CREATE TABLE AlbumSong (
    albumName VARCHAR(100),
    CID INTEGER,
    SID INTEGER,

    PRIMARY KEY (albumName, CID, SID),

    FOREIGN KEY (albumName, CID)
        REFERENCES Album(albumName, CID),

    FOREIGN KEY (SID)
        REFERENCES Song(SID)
);

CREATE TABLE AlbumArtist (
    albumName VARCHAR(100),
    CID INTEGER,
    AID INTEGER,

    PRIMARY KEY (albumName, CID, AID),

    FOREIGN KEY (albumName, CID)
        REFERENCES Album(albumName, CID),

    FOREIGN KEY (AID)
        REFERENCES Artist(AID)
);


CREATE TABLE Genre (
    genreID INTEGER PRIMARY KEY,
    genreName VARCHAR(100),
    popularity NUMBER
);


CREATE TABLE SongGenre (
    SID INTEGER,
    genreID INTEGER,

    PRIMARY KEY (SID, genreID),

    FOREIGN KEY (SID)
        REFERENCES Song(SID),

    FOREIGN KEY (genreID)
        REFERENCES Genre(genreID)
);


CREATE TABLE AppUsers (
    username VARCHAR(100) PRIMARY KEY,
    password VARCHAR(100) NOT NULL,

    birthdate DATE,
    gender VARCHAR(50),
    zip VARCHAR(10),
    subscription_tier VARCHAR(100),

    FOREIGN KEY (subscription_tier) REFERENCES SubscriptionFee(subscription_tier),
    FOREIGN KEY (zip) REFERENCES ZipInfo(zip)
);


CREATE TABLE Playlist (
    name VARCHAR(100),
    username VARCHAR(100),
    listens INTEGER DEFAULT 0,

    PRIMARY KEY (name, username),

    FOREIGN KEY (username)
        REFERENCES AppUsers(username)
);




CREATE TABLE FriendOf (
    inviter_username VARCHAR(100),
    accepter_username VARCHAR(100),

    PRIMARY KEY (inviter_username, accepter_username),

    FOREIGN KEY (inviter_username)
        REFERENCES AppUsers(username),

    FOREIGN KEY (accepter_username)
        REFERENCES AppUsers(username)
);


CREATE TABLE CanAccess (
    name VARCHAR(100),
    ownerUsername VARCHAR(100),
    accessorUsername VARCHAR(100),

    PRIMARY KEY (name, ownerUsername, accessorUsername),

    FOREIGN KEY (name, ownerUsername)
        REFERENCES Playlist(name, username),

    FOREIGN KEY (ownerUsername)
        REFERENCES AppUsers(username),

    FOREIGN KEY (accessorUsername)
        REFERENCES AppUsers(username)
);


CREATE TABLE InPlayList (
    name VARCHAR(100),
    username VARCHAR(100),
    SID INTEGER,
    date_time_added TIMESTAMP,
    date_time_last_played TIMESTAMP,

    PRIMARY KEY (name, username, SID),

    FOREIGN KEY (name, username)
        REFERENCES Playlist(name, username),

    FOREIGN KEY (SID)
        REFERENCES Song(SID)
);


CREATE TABLE Favorites (
    name VARCHAR(100),
    username VARCHAR(100),

    PRIMARY KEY (name, username),

    FOREIGN KEY (name, username)
        REFERENCES Playlist(name, username)
);


CREATE TABLE Downloaded (
    name VARCHAR(100),
    username VARCHAR(100),

    PRIMARY KEY (name, username),

    FOREIGN KEY (name, username)
        REFERENCES Playlist(name, username)
);


CREATE TABLE History (
    name VARCHAR(100),
    username VARCHAR(100),

    PRIMARY KEY (name, username),

    FOREIGN KEY (name, username)
        REFERENCES Playlist(name, username)
);

INSERT INTO ZipInfo VALUES ('01267', 'Williamstown', 'MA');
INSERT INTO ZipInfo VALUES ('02139', 'Cambridge', 'MA');
INSERT INTO ZipInfo VALUES ('10001', 'New York', 'NY');
INSERT INTO ZipInfo VALUES ('94103', 'San Francisco', 'CA');
INSERT INTO ZipInfo VALUES ('60601', 'Chicago', 'IL');
INSERT INTO ZipInfo VALUES ('90012', 'Los Angeles', 'CA');
INSERT INTO ZipInfo VALUES ('30303', 'Atlanta', 'GA');
INSERT INTO ZipInfo VALUES ('77001', 'Houston', 'TX');
INSERT INTO ZipInfo VALUES ('98101', 'Seattle', 'WA');
INSERT INTO ZipInfo VALUES ('33101', 'Miami', 'FL');

INSERT INTO SubscriptionFee VALUES ('Free',    0.00);
INSERT INTO SubscriptionFee VALUES ('Student', 5.99);
INSERT INTO SubscriptionFee VALUES ('Premium', 10.99);
INSERT INTO SubscriptionFee VALUES ('Family',  16.99);
INSERT INTO SubscriptionFee VALUES ('HiFi',    19.99);

INSERT INTO Artist VALUES (0, 'Joe Maphis', 'American');
INSERT INTO Artist VALUES (1, 'Patty Stoneman', 'American');
INSERT INTO Artist VALUES (2, 'Betty Jean Robinson', 'American');
INSERT INTO Artist VALUES (3, 'Jacky Cheung', 'Chinese');
INSERT INTO Artist VALUES (4, 'Eason Chan', 'Chinese');
INSERT INTO Artist VALUES (5, 'eason and the duo band', 'Chinese');
INSERT INTO Artist VALUES (6, 'Alan Tam', 'Chinese');
INSERT INTO Artist VALUES (7, 'Chicago House Selection', 'American');
INSERT INTO Artist VALUES (8, 'Ka$hhh', 'American');
INSERT INTO Artist VALUES (9, 'DJ Noiz', 'American');
INSERT INTO Artist VALUES (10, 'Donell Lewis', 'American');
INSERT INTO Artist VALUES (11, 'Konecs', 'American');
INSERT INTO Artist VALUES (12, 'Cessmun', 'American');
INSERT INTO Artist VALUES (13, 'Bakar', 'British');
INSERT INTO Artist VALUES (14, 'Johann Sebastian Bach', 'German');
INSERT INTO Artist VALUES (15, 'Angela Hewitt', 'Canadian');
INSERT INTO Artist VALUES (16, 'El Ray', 'American');
INSERT INTO Artist VALUES (17, 'Skrizzly Adams', 'American');
INSERT INTO Artist VALUES (18, 'LarryBurdd', 'American');
INSERT INTO Artist VALUES (19, 'Big Smack', 'American');
INSERT INTO Artist VALUES (20, 'Wolfgang Amadeus Mozart', 'Austrian');
INSERT INTO Artist VALUES (21, 'Marc-André Hamelin', 'Canadian');
INSERT INTO Artist VALUES (22, 'Ludwig van Beethoven', 'German');
INSERT INTO Artist VALUES (23, 'Frédéric Chopin', 'Polish');
INSERT INTO Artist VALUES (24, 'poptropicaslutz!', 'American');
INSERT INTO Artist VALUES (25, 'aldrch', 'American');
INSERT INTO Artist VALUES (26, 'Extreme Music', 'British');
INSERT INTO Artist VALUES (27, 'Progressive House Sessions', 'American');
INSERT INTO Artist VALUES (28, 'EzeBoss', 'American');
INSERT INTO Artist VALUES (29, 'Destructo', 'American');
INSERT INTO Artist VALUES (30, 'Dimension', 'American');
INSERT INTO Artist VALUES (31, 'The Weeknd', 'Canadian');
INSERT INTO Artist VALUES (32, 'Drake', 'Canadian');
INSERT INTO Artist VALUES (33, 'Taylor Swift', 'American');
INSERT INTO Artist VALUES (34, 'Arijit Singh', 'Indian');
INSERT INTO Artist VALUES (35, 'Travis Scott', 'American');
INSERT INTO Artist VALUES (36, 'Lana Del Rey', 'American');
INSERT INTO Artist VALUES (37, 'Kendrick Lamar', 'American');

--Eason Chan (4) is a member of eason and the duo band (5)
INSERT INTO MemberOf VALUES (4,5);
INSERT INTO MemberOf VALUES (9, 7);
INSERT INTO MemberOf VALUES (11, 7);
INSERT INTO MemberOf VALUES (12, 7);
INSERT INTO MemberOf VALUES (29, 27);
INSERT INTO MemberOf VALUES (30, 27);

-- Song (SID, songName, length_ms, releaseYear, listens, link_to_source, popularity)
INSERT INTO Song VALUES (0, 'Foggy Mountain Breakdown', 133000, 1961, 870000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 29);
INSERT INTO Song VALUES (1, 'Blue Ridge Mountain Blues', 122960, 1958, 430000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 18);
INSERT INTO Song VALUES (2, 'Tramp on the Street', 228173, 1944, 560000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 27);
INSERT INTO Song VALUES (3, '祇想一生跟你走', 311800, 1993, 210000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 6);
INSERT INTO Song VALUES (4, '可一可再', 287573, 2000, 180000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 2);
INSERT INTO Song VALUES (5, '天堂的花火', 214312, 2003, 95000,   'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 2);
INSERT INTO Song VALUES (6, 'Power Flexible', 167680, 2012, 42000,   'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 0);
INSERT INTO Song VALUES (7, 'Dancefloor Upbeat', 175281, 2013, 38000,   'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 0);
INSERT INTO Song VALUES (8, 'Basement Synth', 186697, 2014, 51000,   'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 0);
INSERT INTO Song VALUES (9, 'Chill', 108000, 2016, 920000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 39);
INSERT INTO Song VALUES (11,  'Chill', 223293, 2018, 870000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 37);
INSERT INTO Song VALUES (10, 'Chill', 159807, 2017, 1100000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 43);
INSERT INTO Song VALUES (12, 'French Suite No. 5 in G Major, BWV 816: II. Courante',  97173, 1995, 340000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 19);
INSERT INTO Song VALUES (13, 'French Suite No. 4 in E-Flat Major, BWV 815a: VI. Menuet', 62640, 1995, 280000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 17);
INSERT INTO Song VALUES (14, 'French Overture (Partita), BWV 831: III. Gavotte I', 83253, 1995, 260000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 17);
INSERT INTO Song VALUES (15, 'Garage', 139818, 2019, 710000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 26);
INSERT INTO Song VALUES (16, 'Garage', 155876, 2020, 540000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 22);
INSERT INTO Song VALUES (17, 'Garage', 214218, 2021, 390000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 14);
INSERT INTO Song VALUES (18, 'Piano Sonata No. 16 in C Major, K. 545: III. Rondo',    95520, 2015, 450000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 18);
INSERT INTO Song VALUES (19, 'Piano Sonata No. 12 in A-Flat Major, Op. 26: Ia. Theme', 72920, 2010, 310000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 17);
INSERT INTO Song VALUES (20, 'Piano Sonata No. 2 in B-Flat Minor, Op. 35: IV. Finale', 104933, 2009, 290000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 16);
INSERT INTO Song VALUES (21, 'Guestlist''r', 96204, 2024, 780000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 30);
INSERT INTO Song VALUES (22, 'Clandestine Meetings', 136941, 2024, 640000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 27);
INSERT INTO Song VALUES (23, 'Two To Tango', 139842, 2024, 620000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 27);
INSERT INTO Song VALUES (24, 'Hero', 239413, 2015, 480000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 21);
INSERT INTO Song VALUES (25, 'Fade Away', 229386, 2015, 320000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 13);
INSERT INTO Song VALUES (26, 'Let It Roll', 184981, 2015, 110000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 3);
INSERT INTO Song VALUES (27, 'Experience Hot', 163866, 2011, 28000,   'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 0);
INSERT INTO Song VALUES (28, 'Terrace Record', 196231, 2011, 31000,   'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 0);
INSERT INTO Song VALUES (29, 'Warehouse Flying', 182909, 2012, 24000,   'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 0);
INSERT INTO Song VALUES (30, 'Techno', 69600, 2013, 760000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 30);
INSERT INTO Song VALUES (31, 'Techno', 225306, 2015, 890000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 33);
INSERT INTO Song VALUES (32, 'Techno', 263793, 2017, 910000,  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 33);
INSERT INTO Song VALUES (101, 'Blinding Lights', 200000, 2020, 5420000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 95);
INSERT INTO Song VALUES (102, 'God''s Plan', 217000, 2018, 4890000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 92);
INSERT INTO Song VALUES (103, 'Shake It Off', 231000, 2014, 4310000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 88);
INSERT INTO Song VALUES (104, 'Tum Hi Ho', 269000, 2023, 3120000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 85);
INSERT INTO Song VALUES (105, 'SICKO MODE', 312000, 2018, 6010000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 91);
INSERT INTO Song VALUES (106, 'Video Games', 284000, 2012, 2780000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 80);
INSERT INTO Song VALUES (107, 'HUMBLE.', 225000, 2017, 5210000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 90);
INSERT INTO Song VALUES (108, 'Cruel Summer', 203000, 2022, 3550000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 93);
INSERT INTO Song VALUES (109, 'HIGHEST IN THE ROOM', 198000, 2021, 2980000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 83);
INSERT INTO Song VALUES (110, 'Save Your Tears', 246000, 2016, 4720000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 89);
INSERT INTO Song VALUES (111, 'In Your Eyes', 238000, 2020, 3800000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 87);
INSERT INTO Song VALUES (112, 'Starboy', 230000, 2016, 4100000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 88);
INSERT INTO Song VALUES (113, 'One Dance', 174000, 2016, 5500000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 91);
INSERT INTO Song VALUES (114, 'Nonstop', 211000, 2018, 3200000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 84);
INSERT INTO Song VALUES (115, 'Anti-Hero', 200000, 2022, 6200000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 96);
INSERT INTO Song VALUES (116, 'Love Story', 235000, 2008, 3900000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 82);
INSERT INTO Song VALUES (117, 'Summertime Sadness', 265000, 2012, 3000000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 81);
INSERT INTO Song VALUES (118, 'Young and Beautiful', 252000, 2013, 2600000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 78);
INSERT INTO Song VALUES (119, 'DNA.', 185000, 2017, 4900000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 88);
INSERT INTO Song VALUES (120, 'goosebumps', 244000, 2016, 4400000, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 87);

 
INSERT INTO Sings VALUES (0, 0);
INSERT INTO Sings VALUES (1, 1);
INSERT INTO Sings VALUES (2, 2);
INSERT INTO Sings VALUES (3, 3);
INSERT INTO Sings VALUES (4, 4);
INSERT INTO Sings VALUES (5, 4);
INSERT INTO Sings VALUES (6, 5);
INSERT INTO Sings VALUES (7, 6);
INSERT INTO Sings VALUES (7, 7);
INSERT INTO Sings VALUES (7, 8);
INSERT INTO Sings VALUES (8, 9);
INSERT INTO Sings VALUES (9, 10);
INSERT INTO Sings VALUES (10, 10);
INSERT INTO Sings VALUES (11, 10);
INSERT INTO Sings VALUES (12, 10);
INSERT INTO Sings VALUES (13, 11);
INSERT INTO Sings VALUES (14, 12);
INSERT INTO Sings VALUES (15, 12);
INSERT INTO Sings VALUES (14, 13);
INSERT INTO Sings VALUES (15, 13);
INSERT INTO Sings VALUES (14, 14);
INSERT INTO Sings VALUES (15, 14);
INSERT INTO Sings VALUES (16, 15);
INSERT INTO Sings VALUES (17, 15);
INSERT INTO Sings VALUES (18, 16);
INSERT INTO Sings VALUES (19, 17);
INSERT INTO Sings VALUES (20, 18);
INSERT INTO Sings VALUES (21, 18);
INSERT INTO Sings VALUES (22, 19);
INSERT INTO Sings VALUES (15, 19);
INSERT INTO Sings VALUES (23, 20);
INSERT INTO Sings VALUES (21, 20);
INSERT INTO Sings VALUES (24, 21);
INSERT INTO Sings VALUES (24, 22);
INSERT INTO Sings VALUES (24, 23);
INSERT INTO Sings VALUES (25, 23);
INSERT INTO Sings VALUES (26, 24);
INSERT INTO Sings VALUES (26, 25);
INSERT INTO Sings VALUES (26, 26);
INSERT INTO Sings VALUES (27, 27);
INSERT INTO Sings VALUES (27, 28);
INSERT INTO Sings VALUES (27, 29);
INSERT INTO Sings VALUES (28, 30);
INSERT INTO Sings VALUES (29, 31);
INSERT INTO Sings VALUES (30, 32);
INSERT INTO Sings VALUES (31, 101);
INSERT INTO Sings VALUES (31, 110);
INSERT INTO Sings VALUES (31, 111);
INSERT INTO Sings VALUES (31, 112);
INSERT INTO Sings VALUES (32, 102);
INSERT INTO Sings VALUES (32, 113);
INSERT INTO Sings VALUES (32, 114);
INSERT INTO Sings VALUES (33, 103);
INSERT INTO Sings VALUES (33, 108);
INSERT INTO Sings VALUES (33, 115);
INSERT INTO Sings VALUES (33, 116);
INSERT INTO Sings VALUES (34, 104);
INSERT INTO Sings VALUES (35, 105);
INSERT INTO Sings VALUES (35, 109);
INSERT INTO Sings VALUES (35, 120);
INSERT INTO Sings VALUES (36, 106);
INSERT INTO Sings VALUES (36, 117);
INSERT INTO Sings VALUES (36, 118);
INSERT INTO Sings VALUES (37, 107);
INSERT INTO Sings VALUES (37, 119);
INSERT INTO Sings VALUES (32, 105);
INSERT INTO Sings VALUES (31, 108);

INSERT INTO Company VALUES (0, 'Melody Mountain Records', '01267');
INSERT INTO Company VALUES (1, 'Eas Music Ltd.', '02139');
INSERT INTO Company VALUES (2, 'Hyperion', '10001');
INSERT INTO Company VALUES (3, 'Epitaph', '94103');
INSERT INTO Company VALUES (4, 'The Extreme Music Library Limited', '60601');
INSERT INTO Company VALUES (5, 'Republic Records', '10001');
INSERT INTO Company VALUES (6, 'OVO Sound', '02139');
INSERT INTO Company VALUES (7, 'Universal Music', '90012');
INSERT INTO Company VALUES (8, 'T-Series Music', '60601');
INSERT INTO Company VALUES (9, 'Cactus Jack Records', '94103');
INSERT INTO Company VALUES (10,'Top Dawg Entertainment', '01267');

INSERT INTO Album VALUES ('Bluegrass Gospel', 1991, 0);
INSERT INTO Album VALUES ('L.O.V.E.', 2018, 1);
INSERT INTO Album VALUES ('The French Suites', 1995, 2);
INSERT INTO Album VALUES ('Mozart: Piano Sonatas', 2015, 2);
INSERT INTO Album VALUES ('Beethoven: Piano Sonatas Vol. 3', 2010, 2);
INSERT INTO Album VALUES ('Chopin: Piano Sonatas Nos. 2 and 3', 2009, 2);
INSERT INTO Album VALUES ('Face For The Radio/Voice For A Silent Film (Deluxe)', 2024, 3);
INSERT INTO Album VALUES ('Post Dubstep', 2015, 4);
INSERT INTO Album VALUES ('After Hours', 2020, 5);
INSERT INTO Album VALUES ('Scorpion', 2018, 6);
INSERT INTO Album VALUES ('1989', 2014, 7);
INSERT INTO Album VALUES ('Animal', 2023, 8);
INSERT INTO Album VALUES ('Astroworld', 2018, 9);
INSERT INTO Album VALUES ('Born To Die', 2012, 7);
INSERT INTO Album VALUES ('DAMN.', 2017, 10);
INSERT INTO Album VALUES ('Starboy', 2016, 5);

INSERT INTO AlbumSong VALUES ('Bluegrass Gospel', 0,  2);
INSERT INTO AlbumSong VALUES ('L.O.V.E.', 1,  4);
INSERT INTO AlbumSong VALUES ('The French Suites', 2,  12);
INSERT INTO AlbumSong VALUES ('The French Suites', 2,  13);
INSERT INTO AlbumSong VALUES ('The French Suites', 2,  14);
INSERT INTO AlbumSong VALUES ('Mozart: Piano Sonatas', 2,  18);
INSERT INTO AlbumSong VALUES ('Beethoven: Piano Sonatas Vol. 3', 2,  19);
INSERT INTO AlbumSong VALUES ('Chopin: Piano Sonatas Nos. 2 and 3', 2,  20);
INSERT INTO AlbumSong VALUES ('Face For The Radio/Voice For A Silent Film (Deluxe)', 3,  21);
INSERT INTO AlbumSong VALUES ('Face For The Radio/Voice For A Silent Film (Deluxe)', 3,  22);
INSERT INTO AlbumSong VALUES ('Face For The Radio/Voice For A Silent Film (Deluxe)', 3,  23);
INSERT INTO AlbumSong VALUES ('Post Dubstep', 4,  24);
INSERT INTO AlbumSong VALUES ('Post Dubstep', 4,  25);
INSERT INTO AlbumSong VALUES ('Post Dubstep', 4,  26);
INSERT INTO AlbumSong VALUES ('After Hours', 5,  101);
INSERT INTO AlbumSong VALUES ('After Hours', 5,  110);
INSERT INTO AlbumSong VALUES ('After Hours', 5,  111);
INSERT INTO AlbumSong VALUES ('Starboy', 5,  112);
INSERT INTO AlbumSong VALUES ('Scorpion', 6,  102);
INSERT INTO AlbumSong VALUES ('Scorpion', 6,  113);
INSERT INTO AlbumSong VALUES ('Scorpion', 6,  114);
INSERT INTO AlbumSong VALUES ('1989', 7,  103);
INSERT INTO AlbumSong VALUES ('1989', 7,  108);
INSERT INTO AlbumSong VALUES ('1989', 7,  115);
INSERT INTO AlbumSong VALUES ('1989', 7,  116);
INSERT INTO AlbumSong VALUES ('Animal', 8,  104);
INSERT INTO AlbumSong VALUES ('Astroworld', 9,  105);
INSERT INTO AlbumSong VALUES ('Astroworld', 9,  109);
INSERT INTO AlbumSong VALUES ('Astroworld', 9,  120);
INSERT INTO AlbumSong VALUES ('Born To Die', 7,  106);
INSERT INTO AlbumSong VALUES ('Born To Die', 7,  117);
INSERT INTO AlbumSong VALUES ('Born To Die', 7,  118);
INSERT INTO AlbumSong VALUES ('DAMN.', 10, 107);
INSERT INTO AlbumSong VALUES ('DAMN.', 10, 119);

INSERT INTO AlbumArtist VALUES ('Bluegrass Gospel', 0, 2);
INSERT INTO AlbumArtist VALUES ('L.O.V.E.', 1, 4);
INSERT INTO AlbumArtist VALUES ('L.O.V.E.', 1, 5);
INSERT INTO AlbumArtist VALUES ('The French Suites', 2, 14);
INSERT INTO AlbumArtist VALUES ('The French Suites', 2, 15);
INSERT INTO AlbumArtist VALUES ('Mozart: Piano Sonatas', 2, 20);
INSERT INTO AlbumArtist VALUES ('Mozart: Piano Sonatas', 2, 21);
INSERT INTO AlbumArtist VALUES ('Beethoven: Piano Sonatas Vol. 3', 2, 22);
INSERT INTO AlbumArtist VALUES ('Beethoven: Piano Sonatas Vol. 3', 2, 15);
INSERT INTO AlbumArtist VALUES ('Chopin: Piano Sonatas Nos. 2 and 3', 2, 23);
INSERT INTO AlbumArtist VALUES ('Chopin: Piano Sonatas Nos. 2 and 3', 2, 21);
INSERT INTO AlbumArtist VALUES ('Face For The Radio/Voice For A Silent Film (Deluxe)', 3, 24);
INSERT INTO AlbumArtist VALUES ('Face For The Radio/Voice For A Silent Film (Deluxe)', 3, 25);
INSERT INTO AlbumArtist VALUES ('Post Dubstep', 4, 26);
INSERT INTO AlbumArtist VALUES ('After Hours', 5, 31);
INSERT INTO AlbumArtist VALUES ('Starboy', 5, 31);
INSERT INTO AlbumArtist VALUES ('Scorpion', 6, 32);
INSERT INTO AlbumArtist VALUES ('1989', 7, 33);
INSERT INTO AlbumArtist VALUES ('Animal', 8, 34);
INSERT INTO AlbumArtist VALUES ('Astroworld', 9, 35);
INSERT INTO AlbumArtist VALUES ('Born To Die', 7, 36);
INSERT INTO AlbumArtist VALUES ('DAMN.', 10, 37);


INSERT INTO Genre VALUES (1, 'Pop', 88);
INSERT INTO Genre VALUES (2, 'Hip-Hop', 91);
INSERT INTO Genre VALUES (3, 'Rap', 89);
INSERT INTO Genre VALUES (4, 'Indie', 70);
INSERT INTO Genre VALUES (5, 'Bollywood', 75);
INSERT INTO Genre VALUES (6, 'RnB', 82);
INSERT INTO Genre VALUES (7, 'Alternative', 72);
INSERT INTO Genre VALUES (8, 'Classical', 60);
INSERT INTO Genre VALUES (9, 'Bluegrass', 50);
INSERT INTO Genre VALUES (10, 'Electronic', 78);
INSERT INTO Genre VALUES (11, 'House', 74);
INSERT INTO Genre VALUES (12, 'Country', 65);

INSERT INTO SongGenre VALUES (0, 9);
INSERT INTO SongGenre VALUES (1, 9);
INSERT INTO SongGenre VALUES (1, 12);
INSERT INTO SongGenre VALUES (2, 9);
INSERT INTO SongGenre VALUES (3, 1);
INSERT INTO SongGenre VALUES (4, 1);
INSERT INTO SongGenre VALUES (5, 1);
INSERT INTO SongGenre VALUES (6, 10);
INSERT INTO SongGenre VALUES (7, 10);
INSERT INTO SongGenre VALUES (8, 10);
INSERT INTO SongGenre VALUES (8, 11);
INSERT INTO SongGenre VALUES (9, 6);
INSERT INTO SongGenre VALUES (10, 6);
INSERT INTO SongGenre VALUES (11, 6);
INSERT INTO SongGenre VALUES (12, 8);
INSERT INTO SongGenre VALUES (13, 8);
INSERT INTO SongGenre VALUES (14, 8);
INSERT INTO SongGenre VALUES (15, 4);
INSERT INTO SongGenre VALUES (16, 4);
INSERT INTO SongGenre VALUES (17, 4);
INSERT INTO SongGenre VALUES (17, 7);
INSERT INTO SongGenre VALUES (18, 8);
INSERT INTO SongGenre VALUES (19, 8);
INSERT INTO SongGenre VALUES (20, 8);
INSERT INTO SongGenre VALUES (21, 4);
INSERT INTO SongGenre VALUES (22, 4);
INSERT INTO SongGenre VALUES (23, 4);
INSERT INTO SongGenre VALUES (24, 10);
INSERT INTO SongGenre VALUES (25, 10);
INSERT INTO SongGenre VALUES (26, 10);
INSERT INTO SongGenre VALUES (27, 11);
INSERT INTO SongGenre VALUES (28, 11);
INSERT INTO SongGenre VALUES (29, 11);
INSERT INTO SongGenre VALUES (30, 10);
INSERT INTO SongGenre VALUES (31, 10);
INSERT INTO SongGenre VALUES (32, 10);
INSERT INTO SongGenre VALUES (101, 1);
INSERT INTO SongGenre VALUES (101, 6);
INSERT INTO SongGenre VALUES (102, 2);
INSERT INTO SongGenre VALUES (102, 3);
INSERT INTO SongGenre VALUES (103, 1);
INSERT INTO SongGenre VALUES (104, 5);
INSERT INTO SongGenre VALUES (105, 2);
INSERT INTO SongGenre VALUES (105, 3);
INSERT INTO SongGenre VALUES (106, 4);
INSERT INTO SongGenre VALUES (106, 7);
INSERT INTO SongGenre VALUES (107, 2);
INSERT INTO SongGenre VALUES (107, 3);
INSERT INTO SongGenre VALUES (108, 1);
INSERT INTO SongGenre VALUES (109, 2);
INSERT INTO SongGenre VALUES (109, 3);
INSERT INTO SongGenre VALUES (110, 1);
INSERT INTO SongGenre VALUES (110, 6);
INSERT INTO SongGenre VALUES (111, 1);
INSERT INTO SongGenre VALUES (111, 6);
INSERT INTO SongGenre VALUES (112, 1);
INSERT INTO SongGenre VALUES (112, 6);
INSERT INTO SongGenre VALUES (113, 2);
INSERT INTO SongGenre VALUES (113, 6);
INSERT INTO SongGenre VALUES (114, 2);
INSERT INTO SongGenre VALUES (114, 3);
INSERT INTO SongGenre VALUES (115, 1);
INSERT INTO SongGenre VALUES (116, 1);
INSERT INTO SongGenre VALUES (116, 12);
INSERT INTO SongGenre VALUES (117, 4);
INSERT INTO SongGenre VALUES (117, 7);
INSERT INTO SongGenre VALUES (118, 4);
INSERT INTO SongGenre VALUES (119, 2);
INSERT INTO SongGenre VALUES (119, 3);
INSERT INTO SongGenre VALUES (120, 2);
INSERT INTO SongGenre VALUES (120, 3);


INSERT INTO AppUsers VALUES ('tashrique', 'tashpass123',  DATE '2003-08-12', 'M', '01267', 'Student');
INSERT INTO AppUsers VALUES ('dean', 'deanpass123',  DATE '2003-04-21', 'M', '02139', 'Premium');
INSERT INTO AppUsers VALUES ('gavin', 'gavinpass123', DATE '2003-11-03', 'M', '10001', 'Premium');
INSERT INTO AppUsers VALUES ('oishy', 'oishypass123',DATE '2002-06-17', 'F', '94103', 'Family');
INSERT INTO AppUsers VALUES ('omar', 'omarpass123',  DATE '2001-09-09', 'M', '60601', 'Free');
INSERT INTO AppUsers VALUES ('lina', 'linapass123',  DATE '2004-01-25', 'F', '90012', 'HiFi');
INSERT INTO AppUsers VALUES ('zara', 'zarapass123',  DATE '2002-12-01', 'F', '30303', 'Student');
INSERT INTO AppUsers VALUES ('marcus', 'marcuspass123', DATE '2000-03-15','M', '77001', 'Premium');
INSERT INTO AppUsers VALUES ('priya', 'priyapass123', DATE '2001-07-22', 'F', '98101', 'Student');
INSERT INTO AppUsers VALUES ('milton', 'miltonpass123',   DATE '1999-11-30', 'M', '33101', 'Free');

INSERT INTO Playlist VALUES ('Late Night Walk', 'tashrique', 148);
INSERT INTO Playlist VALUES ('Road Trip', 'tashrique', 73);
INSERT INTO Playlist VALUES ('CS335 Grind', 'dean', 87);
INSERT INTO Playlist VALUES ('Classical Hours', 'dean', 115);
INSERT INTO Playlist VALUES ('Gym PR', 'gavin', 201);
INSERT INTO Playlist VALUES ('Soft Girl Fall', 'oishy', 164);
INSERT INTO Playlist VALUES ('Commute Mix', 'omar', 59);
INSERT INTO Playlist VALUES ('2am Feelings', 'lina', 132);
INSERT INTO Playlist VALUES ('Desi + Drake', 'zara', 176);
INSERT INTO Playlist VALUES ('Houston Vibes', 'marcus', 94);
INSERT INTO Playlist VALUES ('Study Lo-fi', 'priya', 210);
INSERT INTO Playlist VALUES ('Chill Sundays', 'milton', 41);

INSERT INTO FriendOf VALUES ('tashrique', 'dean');
INSERT INTO FriendOf VALUES ('tashrique', 'gavin');
INSERT INTO FriendOf VALUES ('dean', 'oishy');
INSERT INTO FriendOf VALUES ('gavin', 'omar');
INSERT INTO FriendOf VALUES ('lina', 'zara');
INSERT INTO FriendOf VALUES ('zara', 'tashrique');
INSERT INTO FriendOf VALUES ('omar', 'dean');
INSERT INTO FriendOf VALUES ('marcus', 'gavin');
INSERT INTO FriendOf VALUES ('priya', 'zara');
INSERT INTO FriendOf VALUES ('milton', 'omar');
INSERT INTO FriendOf VALUES ('marcus', 'tashrique');
INSERT INTO FriendOf VALUES ('priya', 'lina');

INSERT INTO CanAccess VALUES ('Late Night Walk', 'tashrique', 'dean');
INSERT INTO CanAccess VALUES ('Late Night Walk', 'tashrique', 'gavin');
INSERT INTO CanAccess VALUES ('CS335 Grind', 'dean', 'tashrique');
INSERT INTO CanAccess VALUES ('Classical Hours', 'dean', 'tashrique');
INSERT INTO CanAccess VALUES ('Gym PR', 'gavin', 'omar');
INSERT INTO CanAccess VALUES ('Gym PR', 'gavin', 'marcus');
INSERT INTO CanAccess VALUES ('Soft Girl Fall', 'oishy', 'dean');
INSERT INTO CanAccess VALUES ('2am Feelings', 'lina', 'zara');
INSERT INTO CanAccess VALUES ('Desi + Drake', 'zara', 'tashrique');
INSERT INTO CanAccess VALUES ('Houston Vibes', 'marcus', 'gavin');
INSERT INTO CanAccess VALUES ('Study Lo-fi', 'priya', 'zara');
INSERT INTO CanAccess VALUES ('Road Trip', 'tashrique', 'marcus');

INSERT INTO InPlayList VALUES ('Late Night Walk', 'tashrique', 101, TIMESTAMP '2026-04-01 22:15:00', TIMESTAMP '2026-04-14 23:48:00');
INSERT INTO InPlayList VALUES ('Late Night Walk', 'tashrique', 106, TIMESTAMP '2026-04-02 00:10:00', TIMESTAMP '2026-04-13 01:05:00');
INSERT INTO InPlayList VALUES ('Late Night Walk', 'tashrique', 110, TIMESTAMP '2026-04-02 00:14:00', TIMESTAMP '2026-04-14 23:52:00');
INSERT INTO InPlayList VALUES ('Late Night Walk', 'tashrique', 9, TIMESTAMP '2026-04-03 01:00:00', TIMESTAMP '2026-04-15 00:10:00');
INSERT INTO InPlayList VALUES ('Road Trip', 'tashrique', 103, TIMESTAMP '2026-04-12 09:00:00', TIMESTAMP '2026-04-14 10:00:00');
INSERT INTO InPlayList VALUES ('Road Trip', 'tashrique', 115, TIMESTAMP '2026-04-12 09:05:00', TIMESTAMP '2026-04-14 10:05:00');
INSERT INTO InPlayList VALUES ('Road Trip', 'tashrique', 116, TIMESTAMP '2026-04-12 09:10:00', TIMESTAMP '2026-04-14 10:10:00');
INSERT INTO InPlayList VALUES ('CS335 Grind', 'dean', 107, TIMESTAMP '2026-04-03 19:00:00', TIMESTAMP '2026-04-14 02:11:00');
INSERT INTO InPlayList VALUES ('CS335 Grind', 'dean', 102, TIMESTAMP '2026-04-03 19:03:00', TIMESTAMP '2026-04-13 23:42:00');
INSERT INTO InPlayList VALUES ('CS335 Grind', 'dean', 105, TIMESTAMP '2026-04-03 19:05:00', TIMESTAMP '2026-04-13 23:57:00');
INSERT INTO InPlayList VALUES ('CS335 Grind', 'dean', 115, TIMESTAMP '2026-04-04 10:00:00', TIMESTAMP '2026-04-14 11:30:00');
INSERT INTO InPlayList VALUES ('CS335 Grind', 'dean', 106,   TIMESTAMP '2026-04-11 14:10:00', TIMESTAMP '2026-04-14 15:20:00');
INSERT INTO InPlayList VALUES ('CS335 Grind', 'dean', 117,   TIMESTAMP '2026-04-11 14:10:00', TIMESTAMP '2026-04-14 15:20:00');
INSERT INTO InPlayList VALUES ('CS335 Grind', 'dean', 118,   TIMESTAMP '2026-04-11 14:10:00', TIMESTAMP '2026-04-14 15:20:00');
INSERT INTO InPlayList VALUES ('Classical Hours', 'dean', 12,  TIMESTAMP '2026-04-13 20:00:00', TIMESTAMP '2026-04-14 21:00:00');
INSERT INTO InPlayList VALUES ('Classical Hours', 'dean', 13,  TIMESTAMP '2026-04-13 20:05:00', TIMESTAMP '2026-04-14 21:10:00');
INSERT INTO InPlayList VALUES ('Classical Hours', 'dean', 18,  TIMESTAMP '2026-04-13 20:10:00', TIMESTAMP '2026-04-14 21:20:00');
INSERT INTO InPlayList VALUES ('Classical Hours', 'dean', 19,  TIMESTAMP '2026-04-13 20:15:00', TIMESTAMP '2026-04-14 21:30:00');
INSERT INTO InPlayList VALUES ('Classical Hours', 'dean', 20,  TIMESTAMP '2026-04-13 20:20:00', TIMESTAMP '2026-04-14 21:40:00');
INSERT INTO InPlayList VALUES ('Gym PR', 'gavin', 105, TIMESTAMP '2026-04-04 17:20:00', TIMESTAMP '2026-04-14 18:30:00');
INSERT INTO InPlayList VALUES ('Gym PR', 'gavin', 107, TIMESTAMP '2026-04-04 17:22:00', TIMESTAMP '2026-04-14 18:34:00');
INSERT INTO InPlayList VALUES ('Gym PR', 'gavin', 109, TIMESTAMP '2026-04-04 17:24:00', TIMESTAMP '2026-04-14 18:36:00');
INSERT INTO InPlayList VALUES ('Gym PR', 'gavin', 120, TIMESTAMP '2026-04-05 09:00:00', TIMESTAMP '2026-04-14 18:40:00');
INSERT INTO InPlayList VALUES ('Soft Girl Fall', 'oishy', 103, TIMESTAMP '2026-04-05 21:00:00', TIMESTAMP '2026-04-13 22:15:00');
INSERT INTO InPlayList VALUES ('Soft Girl Fall', 'oishy', 106, TIMESTAMP '2026-04-05 21:05:00', TIMESTAMP '2026-04-13 22:20:00');
INSERT INTO InPlayList VALUES ('Soft Girl Fall', 'oishy', 108, TIMESTAMP '2026-04-05 21:07:00', TIMESTAMP '2026-04-14 00:05:00');
INSERT INTO InPlayList VALUES ('Soft Girl Fall', 'oishy', 116, TIMESTAMP '2026-04-06 20:00:00', TIMESTAMP '2026-04-14 21:00:00');
INSERT INTO InPlayList VALUES ('Commute Mix', 'omar', 102, TIMESTAMP '2026-04-06 08:10:00', TIMESTAMP '2026-04-14 08:35:00');
INSERT INTO InPlayList VALUES ('Commute Mix', 'omar', 101, TIMESTAMP '2026-04-06 08:14:00', TIMESTAMP '2026-04-14 08:39:00');
INSERT INTO InPlayList VALUES ('Commute Mix', 'omar', 107, TIMESTAMP '2026-04-06 08:18:00', TIMESTAMP '2026-04-14 08:43:00');
INSERT INTO InPlayList VALUES ('2am Feelings', 'lina', 106, TIMESTAMP '2026-04-07 01:40:00', TIMESTAMP '2026-04-14 01:58:00');
INSERT INTO InPlayList VALUES ('2am Feelings', 'lina', 103, TIMESTAMP '2026-04-07 01:44:00', TIMESTAMP '2026-04-14 02:01:00');
INSERT INTO InPlayList VALUES ('2am Feelings', 'lina', 110, TIMESTAMP '2026-04-07 01:48:00', TIMESTAMP '2026-04-14 02:08:00');
INSERT INTO InPlayList VALUES ('2am Feelings', 'lina', 117, TIMESTAMP '2026-04-07 02:00:00', TIMESTAMP '2026-04-14 02:15:00');
INSERT INTO InPlayList VALUES ('Desi + Drake', 'zara', 104, TIMESTAMP '2026-04-08 20:10:00', TIMESTAMP '2026-04-14 20:55:00');
INSERT INTO InPlayList VALUES ('Desi + Drake', 'zara', 102, TIMESTAMP '2026-04-08 20:14:00', TIMESTAMP '2026-04-14 21:02:00');
INSERT INTO InPlayList VALUES ('Desi + Drake', 'zara', 105, TIMESTAMP '2026-04-08 20:16:00', TIMESTAMP '2026-04-14 21:08:00');
INSERT INTO InPlayList VALUES ('Desi + Drake', 'zara', 113, TIMESTAMP '2026-04-08 20:20:00', TIMESTAMP '2026-04-14 21:15:00');
INSERT INTO InPlayList VALUES ('Houston Vibes', 'marcus', 105, TIMESTAMP '2026-04-09 15:00:00', TIMESTAMP '2026-04-14 16:00:00');
INSERT INTO InPlayList VALUES ('Houston Vibes', 'marcus', 120, TIMESTAMP '2026-04-09 15:05:00', TIMESTAMP '2026-04-14 16:05:00');
INSERT INTO InPlayList VALUES ('Houston Vibes', 'marcus', 109, TIMESTAMP '2026-04-09 15:10:00', TIMESTAMP '2026-04-14 16:10:00');
INSERT INTO InPlayList VALUES ('Houston Vibes', 'marcus', 107, TIMESTAMP '2026-04-09 15:15:00', TIMESTAMP '2026-04-14 16:15:00');
INSERT INTO InPlayList VALUES ('Study Lo-fi', 'priya', 9,   TIMESTAMP '2026-04-10 10:00:00', TIMESTAMP '2026-04-14 12:00:00');
INSERT INTO InPlayList VALUES ('Study Lo-fi', 'priya', 10,  TIMESTAMP '2026-04-10 10:05:00', TIMESTAMP '2026-04-14 12:10:00');
INSERT INTO InPlayList VALUES ('Study Lo-fi', 'priya', 11,  TIMESTAMP '2026-04-10 10:10:00', TIMESTAMP '2026-04-14 12:20:00');
INSERT INTO InPlayList VALUES ('Study Lo-fi', 'priya', 104, TIMESTAMP '2026-04-10 10:15:00', TIMESTAMP '2026-04-14 12:30:00');
INSERT INTO InPlayList VALUES ('Chill Sundays', 'milton', 10,  TIMESTAMP '2026-04-11 14:00:00', TIMESTAMP '2026-04-14 15:00:00');
INSERT INTO InPlayList VALUES ('Chill Sundays', 'milton', 101, TIMESTAMP '2026-04-11 14:05:00', TIMESTAMP '2026-04-14 15:10:00');
INSERT INTO InPlayList VALUES ('Chill Sundays', 'milton', 9,   TIMESTAMP '2026-04-11 14:10:00', TIMESTAMP '2026-04-14 15:20:00');


INSERT INTO Favorites VALUES ('Late Night Walk', 'tashrique');
INSERT INTO Favorites VALUES ('CS335 Grind', 'dean');
INSERT INTO Favorites VALUES ('Classical Hours', 'dean');
INSERT INTO Favorites VALUES ('Gym PR', 'gavin');
INSERT INTO Favorites VALUES ('Soft Girl Fall', 'oishy');
INSERT INTO Favorites VALUES ('Desi + Drake', 'zara');
INSERT INTO Favorites VALUES ('Study Lo-fi', 'priya');
INSERT INTO Favorites VALUES ('Houston Vibes', 'marcus');

INSERT INTO Downloaded VALUES ('Late Night Walk', 'tashrique');
INSERT INTO Downloaded VALUES ('Road Trip', 'tashrique');
INSERT INTO Downloaded VALUES ('Gym PR', 'gavin');
INSERT INTO Downloaded VALUES ('Commute Mix', 'omar');
INSERT INTO Downloaded VALUES ('2am Feelings', 'lina');
INSERT INTO Downloaded VALUES ('Desi + Drake', 'zara');
INSERT INTO Downloaded VALUES ('Study Lo-fi', 'priya');
INSERT INTO Downloaded VALUES ('Houston Vibes', 'marcus');

INSERT INTO History VALUES ('Late Night Walk', 'tashrique');
INSERT INTO History VALUES ('Road Trip', 'tashrique');
INSERT INTO History VALUES ('CS335 Grind', 'dean');
INSERT INTO History VALUES ('Classical Hours', 'dean');
INSERT INTO History VALUES ('Gym PR', 'gavin');
INSERT INTO History VALUES ('Commute Mix', 'omar');
INSERT INTO History VALUES ('2am Feelings', 'lina');
INSERT INTO History VALUES ('Soft Girl Fall', 'oishy');
INSERT INTO History VALUES ('Desi + Drake', 'zara');
INSERT INTO History VALUES ('Houston Vibes', 'marcus');
INSERT INTO History VALUES ('Study Lo-fi', 'priya');
INSERT INTO History VALUES ('Chill Sundays', 'milton');

commit;
// Originally created by Rachel Pottinger at UBC
// Modified by Kelly Shaw in 2026 for Williams CS335
//    Modifications include boiler plate code for connecting from Oracle

const oracledb = require("oracledb");
const { get } = require("./appRouter");
require("dotenv").config();
let poolPromise;

async function initiateConnectionPool() {
  // Replace USER_NAME, PASSWORD with your username and password
  const user = process.env.DB_USER;
  const password = process.env.DB_PASSWORD;

  const connectString = process.env.DB_CONNECTION_STRING;
  let connection;
  try {
    poolPromise = oracledb.createPool({
      user,
      password,
      connectString,
      configDir: process.env.WALLET_LOCATION,
      walletLocation: process.env.WALLET_LOCATION,
      walletPassword: process.env.WALLET_PASSWORD,
      poolAlias: "default",
      njs: {
        poolMin: 1,
        poolMax: 3,
        poolIncrement: 1,
        poolTimeout: 60,
      },
    });
    await poolPromise;
    connection = await oracledb.getConnection();
    console.log("Successfully connected to Oracle Database");
  } catch (err) {
    console.error(err);
  } finally {
  }
}

async function closePoolAndExit() {
  await poolPromise;
  console.log("\nTerminating");
  try {
    // 10 seconds grace period for connections to finish
    await oracledb.getPool().close(10);
    process.exit(0);
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  }
}

process.once("SIGTERM", closePoolAndExit).once("SIGINT", closePoolAndExit);

// ----------------------------------------------------------
// Wrapper to manage OracleDB actions, simplifying connection handling.
async function withOracleDB(action) {
  let connection;
  await poolPromise;

  try {
    // Gets a connection from the default pool
    connection = await oracledb.getConnection();
    return await action(connection);
  } catch (err) {
    console.error(err);
    throw err;
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error(err);
      }
    }
  }
}

async function testOracleConnection() {
  return await withOracleDB(async (connection) => {
    return true;
  }).catch(() => {
    return false;
  });
}
// ----------------------------------------------------------

// getAllArtists
async function getAllArtists() {
  return await withOracleDB(async (conn) => {
    const result = await conn.execute(
      `SELECT aid, artistName, nationality FROM Artist`,
      [],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    return result.rows;
  }).catch(() => []);
}

// getAllUsers
async function getAllUsers() {
  return await withOracleDB(async (conn) => {
    const result = await conn.execute(
      `SELECT username, birthdate, gender, zip, subscription_tier FROM AppUsers`,
      [],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    return result.rows;
  }).catch(() => []);
}

// getAllSongs
async function getAllSongs(limit) {
  return await withOracleDB(async (conn) => {
    const result = await conn.execute(
      `SELECT SID, songName, length_ms, releaseYear, listens, popularity FROM Song FETCH FIRST :limit ROWS ONLY`,
      [limit],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    return result.rows;
  }).catch(() => []);
}

// getAllGenres
async function getAllGenres() {
  return await withOracleDB(async (conn) => {
    const result = await conn.execute(
      `SELECT genreName, popularity FROM Genre`,
      [],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    return result.rows;
  }).catch(() => []);
}

// Get playlist by username
async function getPlaylistsByUser(username) {
  return await withOracleDB(async (conn) => {
    const result = await conn.execute(
      `SELECT name, username, listens FROM Playlist
             WHERE username = :username ORDER BY listens DESC`,
      [username],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    return result.rows;
  }).catch(() => []);
}

// Get all playlists
async function getAllPlaylists() {
  return await withOracleDB(async (conn) => {
    const result = await conn.execute(
      `SELECT name, username, listens FROM Playlist ORDER BY listens DESC`,
      [],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    return result.rows;
  }).catch(() => []);
}

//Insert song into playlist
async function addSongToPlaylist(playlistName, username, sid) {
  if (!playlistName || !username || !sid)
    return { success: false, message: "Missing fields" };
  return await withOracleDB(async (conn) => {
    // check playlist exists
    const playlistCheck = await conn.execute(
      `SELECT name FROM Playlist WHERE LOWER(name) = LOWER(:name) AND LOWER(username) = LOWER(:username)`,
      [playlistName, username],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    if (playlistCheck.rows.length === 0) {
      return {
        success: false,
        message: `Playlist "${playlistName}" not found for user "${username}"`,
      };
    }
    // check song exists
    const songCheck = await conn.execute(
      `SELECT SID FROM Song WHERE SID = :sid`,
      [sid],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    if (songCheck.rows.length === 0) {
      return { success: false, message: `Song with ID ${sid} does not exist` };
    }
    // insert
    await conn.execute(
      `INSERT INTO InPlayList (name, username, SID, date_time_added, date_time_last_played)
             VALUES (:name, :username, :sid, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`,
      [playlistName, username, sid],
      { autoCommit: true },
    );
    return { success: true, message: `Song ${sid} added to "${playlistName}"` };
  }).catch((err) => {
    if (err.errorNum === 1)
      return { success: false, message: "Song is already in this playlist" };
    return { success: false, message: "Insert failed: " + err.message };
  });
}

// Get songs in playlist
async function getSongsInPlaylist(playlistName, username) {
  if (!playlistName || !username)
    return { success: false, message: "Missing fields", data: [] };
  return await withOracleDB(async (conn) => {
    // check playlist exists
    const playlistCheck = await conn.execute(
      `SELECT name FROM Playlist WHERE LOWER(name) = LOWER(:name) AND LOWER(username) = LOWER(:username)`,
      [playlistName, username],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    if (playlistCheck.rows.length === 0) {
      return {
        success: false,
        message: `Playlist "${playlistName}" not found for "${username}"`,
        data: [],
      };
    }
    const result = await conn.execute(
      `SELECT s.SID, s.songName, s.releaseYear, s.listens, s.popularity
             FROM InPlayList ip
             JOIN Song s ON ip.SID = s.SID
             WHERE LOWER(ip.name) = LOWER(:name) AND LOWER(ip.username) = LOWER(:username)
             ORDER BY ip.date_time_added DESC`,
      [playlistName, username],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    return {
      success: true,
      message: `${result.rows.length} song(s) found.`,
      data: result.rows,
    };
  }).catch((err) => ({ success: false, message: err.message, data: [] }));
}

async function updateUser(username, tier, zip, gender) {
    if (!username) return { success: false, message: 'Username required' };
    return await withOracleDB(async (conn) => {
        const check = await conn.execute(
            `SELECT username FROM AppUsers WHERE username = :username`,
            [username],
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );
        if (check.rows.length === 0) {
            return { success: false, message: `User "${username}" not found` };
        }
        const updates = [];
        const binds = {};
        if (tier)   { updates.push(`subscription_tier = :tier`);   binds.tier = tier; }
        if (zip)    { updates.push(`zip = :zip`);                   binds.zip = zip; }
        if (gender) { updates.push(`gender = :gender`);             binds.gender = gender; }

        if (updates.length === 0) {
            return { success: false, message: 'No fields to update' };
        }

        binds.username = username;
        await conn.execute(
            `UPDATE AppUsers SET ${updates.join(', ')} WHERE username = :username`,
            binds,
            { autoCommit: true }
        );
        return { success: true, message: `User "${username}" updated successfully` };
    }).catch((err) => ({ success: false, message: 'Update failed: ' + err.message }));
}

async function getNationalityPopularity() {
  return await withOracleDB(async (conn) => {
    const result = await conn.execute(
      `SELECT nationality, ROUND(SUM(length_ms * listens)/1000/3600) totalListensHRS
			FROM ARTIST
			JOIN SINGS USING (AID)
			JOIN SONG USING (SID)
			GROUP BY nationality
			ORDER BY totalListensHRS DESC`,
      [],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    return result.rows;
  }).catch(() => []);
}

async function getGenrePopularity(minSong) {
  return await withOracleDB(async (conn) => {
    const result = await conn.execute(
      `SELECT genreName, COUNT(SID) totalSongs, ROUND(AVG(s.listens)) avgListens
			FROM GENRE g
			JOIN SONGGENRE sg USING(genreID)
			JOIN SONG s USING(SID)
			GROUP BY genreName
			HAVING COUNT(SID) > :minSong
			ORDER BY avgListens DESC`,
      [minSong],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    return result.rows;
  }).catch(() => []);
}

async function getTopGenreByAvgListens() {
    return await withOracleDB(async (conn) => {
        const result = await conn.execute(
            `SELECT genreName, ROUND(AVG(s.listens)) avgListens
             FROM Genre g
             JOIN SongGenre sg USING(genreID)
             JOIN Song s USING(SID)
             GROUP BY genreName
             HAVING AVG(s.listens) = (
                 SELECT MAX(AVG(s2.listens))
                 FROM SongGenre sg2
                 JOIN Song s2 USING(SID)
                 GROUP BY sg2.genreID
             )`,
            [],
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );
        return result.rows;
    }).catch(() => []);
}

async function getMostCollaboratedSongs() {
    return await withOracleDB(async (conn) => {
        const result = await conn.execute(
            `SELECT s.songName, COUNT(si.AID) artistCount
             FROM Song s
             JOIN Sings si ON s.SID = si.SID
             GROUP BY s.songName
             HAVING COUNT(si.AID) > 1
             ORDER BY artistCount DESC`,
            [],
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );
        return result.rows;
    }).catch(() => []);
}

async function getMostActiveUsers() { 
    return await withOracleDB(async (conn) => {
        const result = await conn.execute(
            `SELECT u.username, u.subscription_tier, COUNT(ip.SID) totalSongs
             FROM AppUsers u
             JOIN Playlist p ON u.username = p.username
             JOIN InPlayList ip ON p.name = ip.name AND p.username = ip.username
             GROUP BY u.username, u.subscription_tier
             ORDER BY totalSongs DESC`,
            [],
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );
        return result.rows;
    }).catch(() => []);
}

async function getUnplayedSongs() {
    return await withOracleDB(async (conn) => {
        const result = await conn.execute(
            `SELECT s.SID, s.songName, s.popularity
             FROM Song s
             WHERE s.SID NOT IN (SELECT DISTINCT SID FROM InPlayList)
             ORDER BY s.popularity DESC`,
            [],
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );
        return result.rows;
    }).catch(() => []);
}


async function getArtistPopularity(minListens) {
  return await withOracleDB(async (conn) => {
    const result = await conn.execute(
      `SELECT artistName, totalListens, songName mostListened, ROUND(s2.listens/totalListens*100, 2) percentListened
			FROM (
				SELECT AID, MAX(s1.listens) maxListens, SUM(s1.listens) totalListens
				FROM ARTIST
				JOIN SINGS USING(AID)
				JOIN SONG s1 USING(SID)
				GROUP BY AID
				HAVING SUM(s1.listens) >= :minListens
			) t
			JOIN SINGS USING(AID)
			RIGHT JOIN SONG s2
			ON t.maxListens = s2.listens
			AND SINGS.sid = s2.sid
			JOIN ARTIST USING(AID)
			ORDER BY totalListens DESC`,
      [minListens],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    return result.rows;
  }).catch(() => []);
}

async function deletePlaylist(playlistName, username) {
  if (!playlistName || !username)
    return { success: false, message: "Missing fields" };
  return await withOracleDB(async (conn) => {
    // check playlist exists first
    const check = await conn.execute(
      `SELECT name FROM Playlist WHERE LOWER(name) = LOWER(:name) AND LOWER(username) = LOWER(:username)`,
      [playlistName, username],
      { outFormat: oracledb.OUT_FORMAT_OBJECT }, // lol
    );
    if (check.rows.length === 0) {
      return {
        success: false,
        message: `Playlist "${playlistName}" not found for "${username}"`,
      };
    }
    // cascade
    await conn.execute(
      `DELETE FROM InPlayList WHERE name = :name AND username = :username`,
      [playlistName, username],
    );
    await conn.execute(
      `DELETE FROM CanAccess WHERE name = :name AND ownerUsername = :username`,
      [playlistName, username],
    );
    await conn.execute(
      `DELETE FROM Favorites WHERE name = :name AND username = :username`,
      [playlistName, username],
    );
    await conn.execute(
      `DELETE FROM Downloaded WHERE name = :name AND username = :username`,
      [playlistName, username],
    );
    await conn.execute(
      `DELETE FROM History WHERE name = :name AND username = :username`,
      [playlistName, username],
    );
    await conn.execute(
      `DELETE FROM Playlist WHERE name = :name AND username = :username`,
      [playlistName, username],
    );
    await conn.commit();
    return {
      success: true,
      message: `Playlist "${playlistName}" deleted successfully`,
    };
  }).catch((err) => ({
    success: false,
    message: "Delete failed: " + err.message,
  }));
}

async function getSongsByArtist(artistName) {
  if (!artistName)
    return { success: false, message: "Please enter an artist name", data: [] };
  return await withOracleDB(async (conn) => {
    const artistCheck = await conn.execute(
      `SELECT AID FROM Artist WHERE LOWER(artistName) = LOWER(:artistName)`,
      [artistName],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    if (artistCheck.rows.length === 0) {
      return {
        success: false,
        message: `Artist "${artistName}" not found`,
        data: [],
      };
    }
    const result = await conn.execute(
      `SELECT DISTINCT a.artistName, s.songName, s.releaseYear, s.listens, al.albumName, g.genreName
             FROM Artist a
             JOIN Sings si ON a.AID = si.AID
             JOIN Song s ON si.SID = s.SID
             LEFT JOIN AlbumSong als ON s.SID = als.SID
             LEFT JOIN Album al ON als.albumName = al.albumName AND als.CID = al.CID
             LEFT JOIN SongGenre sg ON s.SID = sg.SID
             LEFT JOIN Genre g ON sg.genreID = g.genreID
             WHERE LOWER(a.artistName) = LOWER(:artistName)
             ORDER BY s.songName, g.genreName`,
      [artistName],
      { outFormat: oracledb.OUT_FORMAT_OBJECT },
    );
    return {
      success: true,
      message: `${result.rows.length} result(s) found.`,
      data: result.rows,
    };
  }).catch((err) => ({ success: false, message: err.message, data: [] }));
}

// SELECTION, PROJECTION, DIVISION 
// =================================

async function projectSongs(fields) {
  const allowedFields = {
    songName: "s.songName",
    artistName: "a.artistName",
    releaseYear: "s.releaseYear",
    length_ms: "s.length_ms",
    listens: "s.listens",
    popularity: "s.popularity",
    genreName: "g.genreName"
  };

  const selectedFields = [];

  for (const field of fields) {
    if (allowedFields[field]) {
      selectedFields.push(allowedFields[field]);
    }
  }

  if (selectedFields.length === 0) {
    return {
      success: false,
      message: "Please select at least one field.",
      data: []
    };
  }

  return await withOracleDB(async (conn) => {
    const sql = `
      SELECT DISTINCT ${selectedFields.join(", ")}
      FROM Song s, Sings si, Artist a, SongGenre sg, Genre g
      WHERE s.SID = si.SID
        AND si.AID = a.AID
        AND s.SID = sg.SID
        AND sg.genreID = g.genreID
    `;

    const result = await conn.execute(
      sql,
      [],
      { outFormat: oracledb.OUT_FORMAT_OBJECT}
    );

    return {
      success: true,
      message : `${result.rows.length} result(s) found.`,
      data: result.rows
    };
  }).catch((err) => {return { success: false, message: err.message, data: [] }});
}


async function selectSongs(filters) {
  const allowedFields = {
    songName: "s.songName",
    artistName: "a.artistName",
    releaseYear: "s.releaseYear",
    length_ms: "s.length_ms",
    listens: "s.listens",
    popularity: "s.popularity",
    genreName: "g.genreName",
  };

  const allowedOperators = ["=", "<", ">", "<=", ">=", "LIKE"];
  const allowedLogic = ["AND", "OR"];

  const whereParts = [];
  const binds = {};
  
  for (let i = 0; i < filters.length; i++) {
    const filter = filters[i];

    const field = allowedFields[filter.field];
    const operator = filter.operator;
    const value = filter.value;
    const logic = filter.logic;

    if (!field) {
      return {
        success: false,
        message: "Invalid field selected.",
        data: [],
      };
    }

    if (!allowedOperators.includes(operator)) {
      return {
        success: false,
        message: "Invalid operator selected.",
        data: [],
      };
    }

    if (value == undefined || value === null || value === ""){
      return {
        success: false,
        message: "Please enter a value for every condition.",
        data: [],
      };
    }

    let bindValue = value;

    if (operator === "LIKE") {
      bindValue = "%" + value + "%";
    }

    const bindName = "value" + i;

    let condition = `${field} ${operator} :${bindName}`;

    if (i > 0) {
      if (!allowedLogic.includes(logic)) { 
        return {
          success: false,
          message: "Invalid AND/OR connector.",
          data: [],
        };
      }
      condition = `${logic} ${condition}`;
    }
    whereParts.push(condition);
    binds[bindName] = bindValue;
  }

  return await withOracleDB( async (conn) => {
    let sql = `
      SELECT DISTINCT
        s.SID,
        s.songName,
        a.artistName,
        s.releaseYear,
        s.length_ms,
        s.listens,
        s.popularity,
        g.genreName
      FROM Song s, Sings si, Artist a, SongGenre sg, Genre g
      WHERE s.SID = si.SID
        AND si.AID = a.AID
        AND s.SID = sg.SID
        AND sg.genreID = g.genreID
    `;

    if (whereParts.length > 0) {
      sql += " AND (" + whereParts.join(" ") + ")";
    }

    const result = await conn.execute(sql, binds, {
      outFormat: oracledb.OUT_FORMAT_OBJECT,
    });

    return  {
      success: true, 
      message: `${result.rows.length} result(s) found.`,
      data: result.rows,
    };
  }).catch((err) => {
    return {
      success: false,
      message: "Selection query failed: " + err.message,
      data: [],
    };
  });
}


async function getAlbumsForDivision() {
  return await withOracleDB(async (conn) => {
    const result = await conn.execute(
      `SELECT albumName, CID, releaseYear
       FROM Album
       ORDER BY albumName`,
       [],
       {outFormat: oracledb.OUT_FORMAT_OBJECT},
    );

    return {
      success: true,
      message: `${result.rows.length} album(s) found.`,
      data: result.rows,
    };
  }).catch((err) => {
    return {
      success: false,
      message: "Could not load albums: " + err.message,
      data: [],
    };
  });
}


async function divideUsersByAlbum(albumName, cid) {
  if (!albumName || cid === undefined || cid === null || cid === "") {
    return {
      success: false,
      message: "Please select an album",
      data: [],
    };
  }

  return await withOracleDB(async (conn) => {
    const result = await conn.execute(
      `SELECT u.username AS "USERNAME"
       FROM AppUsers u
       WHERE NOT EXISTS (
           SELECT als.SID
           FROM AlbumSong als
           WHERE als.albumName = :albumName
             AND als.CID = :cid
             AND NOT EXISTS (
                 SELECT ip.SID
                 FROM Playlist p, InPlayList ip
                 WHERE p.name = ip.name
                   AND p.username = ip.username
                   AND p.username = u.username
                   AND ip.SID = als.SID
             )
       )
       ORDER BY u.username`,
       [albumName, cid],
       {outFormat: oracledb.OUT_FORMAT_OBJECT},
    );

    console.log("Raw division rows:", result.rows);
    
    return {
      success: true,
      message: `${result.rows.length} user(s) found`,
      data: result.rows,
    };
  }).catch((err) => {
    return {
      success: false,
      message: "Division query failed: " + err.message,
      data: [],
    };
  });
}



async function insertUser(username, password, birthdate, gender, zip, tier) {
    if (!username || !password || !tier) return { success: false, message: 'Missing required fields' };
    return await withOracleDB(async (conn) => {
        if (zip) {
            const zipCheck = await conn.execute(
                `SELECT zip FROM ZipInfo WHERE zip = :zip`,
                [zip],
                { outFormat: oracledb.OUT_FORMAT_OBJECT }
            );
            if (zipCheck.rows.length === 0) {
                return { success: false, message: `ZIP code "${zip}" does not exist` };
            }
        }
        // check tier exists
        const tierCheck = await conn.execute(
            `SELECT subscription_tier FROM SubscriptionFee WHERE subscription_tier = :tier`,
            [tier],
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );
        if (tierCheck.rows.length === 0) {
            return { success: false, message: `Subscription tier "${tier}" does not exist` };
        }
        await conn.execute(
            `INSERT INTO AppUsers (username, password, birthdate, gender, zip, subscription_tier)
             VALUES (:username, :password, TO_DATE(:birthdate, 'YYYY-MM-DD'), :gender, :zip, :tier)`,
            [username, password, birthdate || null, gender || null, zip || null, tier],
            { autoCommit: true }
        );
        return { success: true, message: `User "${username}" created successfully` };
    }).catch((err) => {
        if (err.errorNum === 1) return { success: false, message: `Username "${username}" already exists` };
        return { success: false, message: 'Insert failed: ' + err.message };
    });
}

async function searchSongs(query) {
  if (!query) return [];
  return await withOracleDB(async (conn) => {
    const result = await conn.execute(
      `SELECT SID, songName FROM Song
       WHERE LOWER(songName) LIKE LOWER(:query)
       ORDER BY popularity DESC
       FETCH FIRST 10 ROWS ONLY`,
      [`%${query}%`],
      { outFormat: oracledb.OUT_FORMAT_OBJECT }
    );
    return result.rows;
  }).catch(() => []);
}

// NEW VULNERABLE CODE FOR INJECTION ATTACK
async function vulnerableSongSearch(songName) {
  return await withOracleDB(async (conn) => {
    const sql = `
      SELECT SID, songName, releaseYear, listens
      FROM Song
      WHERE songName = '${songName}'
    `;

    console.log("VULNERABLE SQL:", sql);

    const result = await conn.execute(sql, [], {
      outFormat: oracledb.OUT_FORMAT_OBJECT,
    });

    return {
      success: true,
      message: `${result.rows.length} result(s) found.`,
      data: result.rows,
    };
  }).catch((err) => ({
    success: false,
    message: "Vulnerable search failed: " + err.message,
    data: [],
  }));
}

initiateConnectionPool();

module.exports = {
  testOracleConnection,
  withOracleDB,
  getAllPlaylists,
  getPlaylistsByUser,
  getAllArtists,
  getAllUsers,
  getAllSongs,
  getAllGenres,
  getNationalityPopularity,
  getGenrePopularity,
  getArtistPopularity,
  getSongsInPlaylist,
  addSongToPlaylist,
  deletePlaylist,
  getSongsByArtist,
  projectSongs,
  selectSongs,
  getAlbumsForDivision, 
  divideUsersByAlbum,
  insertUser,
  updateUser,
  getTopGenreByAvgListens,
  getMostCollaboratedSongs,
  getMostActiveUsers,
  getUnplayedSongs,
  searchSongs,
  vulnerableSongSearch,
};

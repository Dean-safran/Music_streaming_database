const express = require("express");
const appConnect = require("./connectApp");

const router = express.Router();

router.get("/check-db-connection", async (req, res) => {
  const isConnect = await appConnect.testOracleConnection();
  if (isConnect) res.send("connected");
  else res.send("unable to connect");
});

router.get("/artists", async (req, res, next) => {
  try {
    const data = await appConnect.getAllArtists();
    res.json({ data });
  } catch (err) {
    next(err);
  }
});

router.get("/users", async (req, res, next) => {
  try {
    const data = await appConnect.getAllUsers();
    res.json({ data });
  } catch (err) {
    next(err);
  }
});

router.get('/songs/search', async (req, res, next) => {
  try {
    const data = await appConnect.searchSongs(req.query.q);
    res.json({ data });
  } catch (err) { next(err); }
});

router.get("/songs/by-artist/:artistName", async (req, res) => {
  const result = await appConnect.getSongsByArtist(
    decodeURIComponent(req.params.artistName),
  );
  if (result.success)
    res.json({ success: true, message: result.message, data: result.data });
  else
    res.status(404).json({ success: false, message: result.message, data: [] });
});

// PROJECTION API POINT
router.post("/songs/project", async (req, res) => {
  const fields = req.body.fields;
  const result = await appConnect.projectSongs(fields);
  if (result.success) {
    res.json({
      success: true,
      message: result.message, 
      data: result.data
    });
  } else {
    res.status(400).json({
      success: false,
      message: result.message,
      data: [],
    });
  }
});

// SELECTION API POINT
router.post("/songs/select", async (req, res) => {
  console.log("HIT /songs/select");
  console.log(req.body);
  try { 
    const filters = req.body.filters || [];

    const result = await appConnect.selectSongs(filters);

    console.log("Selection result:", result);
    
    if (result.success) {
      res.json({
        success: true,
        message: result.message,
        data: result.data,
      })
    } else {
      res.status(400).json({
        success: false,
        message: result.message,
        data:[],
      });
    }
  } catch (err) {
    console.error("Selection route error:", err);
    res.status(500).json({
      success: false,
      message: "Server error: " + err.message,
      data: [],
    });
  }
});

// DIVISION OPTIONS API POINT
router.get("/albums/division-options", async (req, res) => {
  const result = await appConnect.getAlbumsForDivision();

  if (result.success) {
    res.json({
      success: true,
      message: result.message, 
      data: result.data,
    });
  } else {
    res.status(400).json({
      success: false, 
      message: result.message, 
      data: [],
    });
  }
});

// DIVISION API POINT
router.post("/albums/division", async (req, res) => {
  const albumName = req.body.albumName;
  const cid = req.body.cid;

  const result = await appConnect.divideUsersByAlbum(albumName, cid);

  if (result.success) {
    res.json({
      success: true,
      message: result.message, 
      data: result.data,
    });
  } else {
    res.status(400).json({
      success: false, 
      message: result.message, 
      data: [],
    });
  }
});

router.get("/songs/:limit", async (req, res, next) => {
  try {
    const data = await appConnect.getAllSongs(req.params.limit);
    res.json({ data });
  } catch (err) {
    next(err);
  }
});

router.post('/users/update', async (req, res) => {
    const { username, tier, zip, gender } = req.body;
    const result = await appConnect.updateUser(username, tier, zip, gender);
    if (result.success) res.json({ success: true, message: result.message });
    else res.status(400).json({ success: false, message: result.message });
});

router.post('/users/insert', async (req, res) => {
    const { username, password, birthdate, gender, zip, tier } = req.body;
    const result = await appConnect.insertUser(username, password, birthdate, gender, zip, tier);
    if (result.success) res.json({ success: true, message: result.message });
    else res.status(400).json({ success: false, message: result.message });
});

router.get("/genres", async (req, res, next) => {
  try {
    const data = await appConnect.getAllGenres();
    res.json({ data });
  } catch (err) {
    next(err);
  }
});

// Playlists

router.get("/playlists", async (req, res) => {
  const data = await appConnect.getAllPlaylists();
  res.json({ data });
});

router.get("/playlists/:username/:name/songs", async (req, res) => {
  const result = await appConnect.getSongsInPlaylist(
    decodeURIComponent(req.params.name),
    decodeURIComponent(req.params.username),
  );
  if (result.success) res.json({ success: true, data: result.data });
  else
    res.status(404).json({ success: false, message: result.message, data: [] });
});

router.post("/playlists/add-song", async (req, res) => {
  const { playlistName, username, sid } = req.body;
  const result = await appConnect.addSongToPlaylist(
    playlistName,
    username,
    parseInt(sid),
  );
  if (result.success) res.json({ success: true, message: result.message });
  else res.status(400).json({ success: false, message: result.message });
});

router.delete("/playlists/delete", async (req, res) => {
  const { playlistName, username } = req.body;
  const result = await appConnect.deletePlaylist(playlistName, username);
  if (result.success) res.json({ success: true, message: result.message });
  else res.status(400).json({ success: false, message: result.message });
});

router.get("/playlists/:username", async (req, res) => {
  const data = await appConnect.getPlaylistsByUser(req.params.username);
  res.json({ data });
});

router.get('/top-genre', async (req, res, next) => {
    try { res.json({ data: await appConnect.getTopGenreByAvgListens() }); }
    catch (err) { next(err); }
});

router.get('/collaborated-songs', async (req, res, next) => {
    try { res.json({ data: await appConnect.getMostCollaboratedSongs() }); }
    catch (err) { next(err); }
});

router.get('/active-users', async (req, res, next) => {
    try { res.json({ data: await appConnect.getMostActiveUsers() }); }
    catch (err) { next(err); }
});

router.get('/unplayed-songs', async (req, res, next) => {
    try { res.json({ data: await appConnect.getUnplayedSongs() }); }
    catch (err) { next(err); }
});

router.get("/nationality-popularity", async (req, res, next) => {
  try {
    const data = await appConnect.getNationalityPopularity();
    res.json({ data });
  } catch (err) {
    next(err);
  }
});

router.get("/genre-popularity/:minSong", async (req, res, next) => {
  try {
    const data = await appConnect.getGenrePopularity(req.params.minSong);
    res.json({ data });
  } catch (err) {
    next(err);
  }
});

router.get("/artist-popularity/:minListens", async (req, res, next) => {
  try {
    const data = await appConnect.getArtistPopularity(req.params.minListens);
    res.json({ data });
  } catch (err) {
    next(err);
  }
});

// NEW VULNERABLE CODE
router.post("/songs/vulnerable-search", async (req, res) => {
  const songName = req.body.songName;

  const result = await appConnect.vulnerableSongSearch(songName);
  res.json(result);
});

module.exports = router;

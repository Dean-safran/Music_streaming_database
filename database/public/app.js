// Helper funcs
function showSection(id) {
  document
    .querySelectorAll(".section")
    .forEach((s) => s.classList.add("hidden"));
  document.getElementById(id).classList.remove("hidden");
}

function showMsg(elId, text, isSuccess) {
  const el = document.getElementById(elId);
  el.textContent = text;
  el.className = "msg " + (isSuccess ? "success" : "error");
}

function makeTable(rows, columns, displayNames) {
  if (!rows || rows.length === 0)
    return '<p style="color:#666;margin-top:12px">No results found.</p>';

  const cols = columns || Object.keys(rows[0]);
  const headers = displayNames || cols;
  const thead = headers.map((h) => `<th>${h}</th>`).join("");
  const tbody = rows
    .map(
      (row) =>
        "<tr>" +
        cols
          .map((c) => {
            const val = row[c];
            if (typeof val === "string" && val.startsWith("http")) {
              return `<td><a href="${val}" target="_blank">Link</a></td>`;
            }
            return `<td>${val ?? "—"}</td>`;
          })
          .join("") +
        "</tr>",
    )
    .join("");

  return `<table><thead><tr>${thead}</tr></thead><tbody>${tbody}</tbody></table>`;
}

async function checkDbConnection() {
  try {
    const res = await fetch("/check-db-connection");
    const text = await res.text();
    const el = document.getElementById("db-status");
    if (text === "connected") {
      el.textContent = "db_connected🟢";
      el.className = "db-status ok";
    } else {
      el.textContent = "db_notConnected🔴";
      el.className = "db-status err";
    }
  } catch {
    document.getElementById("db-status").textContent = "🔴";
    document.getElementById("db-status").className = "db-status err";
  }
}

checkDbConnection();

async function loadArtists() {
  const res = await fetch("/artists");
  const { data } = await res.json();
  document.getElementById("artists-table").innerHTML = makeTable(
    data,
    ["AID", "ARTISTNAME", "NATIONALITY"],
    ["ID", "Artist Name", "Nationality"],
  );
}

async function loadUsers() {
  const res = await fetch("/users");
  const { data } = await res.json();

  const formatted = data.map((row) => ({
    ...row,
    BIRTHDATE: row.BIRTHDATE
      ? new Date(row.BIRTHDATE).toISOString().slice(0, 10)
      : "—",
  }));

  document.getElementById("users-table").innerHTML = makeTable(
    formatted,
    ["USERNAME", "BIRTHDATE", "GENDER", "SUBSCRIPTION_TIER"],
    ["Username", "Birthdate", "Gender", "Subscription Tier"],
  );
}

async function loadUsersForUpdate() {
  const res = await fetch("/users");
  const { data } = await res.json();
  if (!data || data.length === 0) return;
  document.getElementById("update-user-list").innerHTML =
    '<p style="color:#888;font-size:0.85rem">Click a user to select:</p>' +
    data
      .map(
        (u) =>
          `<button onclick="document.getElementById('update-username').value='${u.USERNAME}'"
             style="margin:4px;background:#2a2a2a;color:#ccc;border:1px solid #444">
             ${u.USERNAME} (${u.SUBSCRIPTION_TIER})</button>`,
      )
      .join("");
}

async function updateUser() {
  const username = document.getElementById("update-username").value.trim();
  const tier = document.getElementById("update-tier").value;
  const zip = document.getElementById("update-zip").value.trim();
  const gender = document.getElementById("update-gender").value;

  if (!username) {
    showMsg("user-update-msg", "Please select or enter a username.", false);
    return;
  }
  if (!tier && !zip && !gender) {
    showMsg("user-update-msg", "Please change at least one field.", false);
    return;
  }

  try {
    const res = await fetch("/users/update", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, tier, zip, gender }),
    });
    const data = await res.json();
    showMsg("user-update-msg", data.message, data.success);
    if (data.success) loadUsers();
  } catch {
    showMsg("user-update-msg", "Request failed.", false);
  }
}

async function insertUser() {
  const username = document.getElementById("new-username").value.trim();
  const password = document.getElementById("new-password").value.trim();
  const birthdate = document.getElementById("new-birthdate").value.trim();
  const gender = document.getElementById("new-gender").value;
  const zip = document.getElementById("new-zip").value.trim();
  const tier = document.getElementById("new-tier").value;

  if (!username || !password || !tier) {
    showMsg(
      "user-insert-msg",
      "Username, password, and tier are required.",
      false,
    );
    return;
  }

  try {
    const res = await fetch("/users/insert", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        username,
        password,
        birthdate,
        gender,
        zip,
        tier,
      }),
    });
    const data = await res.json();
    showMsg("user-insert-msg", data.message, data.success);
    if (data.success) loadUsers();
  } catch {
    showMsg("user-insert-msg", "Request failed.", false);
  }
}

async function loadSongs() {
  const limitInput = document.getElementById("song-limit");
  const limit = parseInt(limitInput.value);
  const res = await fetch(`/songs/${encodeURIComponent(limit)}`);
  const { data } = await res.json();
  document.getElementById("songs-table").innerHTML = makeTable(
    data,
    ["SID", "SONGNAME", "LENGTH_MS", "RELEASEYEAR", "LISTENS"],
    ["Song ID", "Song Name", "Length (ms)", "Year", "Listens"],
  );
}

async function loadGenres() {
  const res = await fetch("/genres");
  const { data } = await res.json();
  document.getElementById("genres-table").innerHTML = makeTable(
    data,
    ["GENRENAME", "POPULARITY"],
    ["Genre", "Popularity"],
  );
}

async function projectSongs() {
  const checkedBoxes = document.querySelectorAll(".project-field:checked");

  const fields = Array.from(checkedBoxes).map((box) => box.value);

  if (fields.length == 0) {
    showMsg("song-projection-msg", "Please select at least one field.", false);
    document.getElementById("song-projection-table").innerHTML = "";
    return;
  }

  try {
    const res = await fetch("/songs/project", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ fields }),
    });

    const result = await res.json();

    if (!result.success) {
      showMsg("song-projection-msg", result.message, false);
      document.getElementById("song-projection-table").innerHTML = "";
      return;
    }

    showMsg("song-projection-msg", result.message, true);
    document.getElementById("song-projection-table").innerHTML = makeTable(
      result.data,
    );
  } catch {
    showMsg("song-projection-msg", "Request failed.", false);
    document.getElementById("song-projection-table").innerHTML = "";
  }
}

async function selectSongs() {
  const rows = document.querySelectorAll(".selection-row");
  const filters = [];

  rows.forEach((row, index) => {
    const field = row.querySelector(".select-field").value;
    const operator = row.querySelector(".select-operator").value;
    const value = row.querySelector(".select-value").value.trim();

    let logic = "AND";
    const logicBox = row.querySelector(".select-logic");
    if (logicBox) {
      logic = logicBox.value;
    }

    // Skip optional blank rows
    if (field === "" && value === "") {
      return;
    }
    
    // If they chose a field but forgot value, catch it
    if (field !== "" && value === "") {
      showMsg("song-selection-msg", "Please enter a value for every selected condition", false);
      document.getElementById("song-selection-table").innerHTML = "";
      return;
    }

    const filter = {
      field: field,
      operator: operator,
      value: value,
    };

    // First condition does not need AND/OR
    if (index > 0) {
      filter.logic = logic;
    }

    filters.push(filter);
  });

  if (filters.length === 0) {
    showMsg("song-selection-msg", "Please enter at least one condition", false);
    document.getElementById("song-selection-table").innerHTML = "";
    return;
  }

  try {
    const res = await fetch("/songs/select", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({filters: filters}),
    });

    const result = await res.json();

    if (!result.success) {
      showMsg("song-selection-msg", result.message, false);
      document.getElementById("song-selection-table").innerHTML = "";
      return;
    }

    showMsg("song-selection-msg", result.message, true);
    document.getElementById("song-selection-table").innerHTML = makeTable(
      result.data,
      [
        "SID",
        "SONGNAME",
        "ARTISTNAME",
        "RELEASEYEAR",
        "LENGTH_MS",
        "LISTENS",
        "POPULARITY",
        "GENRENAME",
      ],
    );
  } catch (err) {
    console.error(err);
    showMsg("song-selection-msg", "Request failed: " + err.message, false);
    document.getElementById("song-selection-table").innerHTML = "";
  }
}

async function loadDivisionAlbums() {
  try {
    const res = await fetch("/albums/division-options");
    const result = await res.json();

    const dropdown = document.getElementById("division-album-select");
    dropdown.innerHTML = "";

    if (!result.success) {
      dropdown.innerHTML = `<option value="">Could not load albums</option>`;
      showMsg("album-division-msg", result.message, false);
      return;
    }

    dropdown.innerHTML = `<option value="">Select an album</option>`;

    result.data.forEach((album) => {
      const option = document.createElement("option");

      option.value = JSON.stringify({
        albumName: album.ALBUMNAME,
        cid: album.CID,
      });

      option.textContent =
        album.ALBUMNAME + " (" + album.RELEASEYEAR + ")";

      dropdown.appendChild(option);
    });
  } catch {
    showMsg("album-division-msg", "Could not load album options.", false);
  }
}

async function runAlbumDivision() {
  const dropdown = document.getElementById("division-album-select");
  const selectedValue = dropdown.value;

  if (!selectedValue) {
    showMsg("album-division-msg", "Please select an album.", false);
    document.getElementById("album-division-table").innerHTML = "";
    return;
  }

  const selectedAlbum = JSON.parse(selectedValue);

  try {
    const res = await fetch("/albums/division", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(selectedAlbum),
    });

    const result = await res.json();

    if (!result.success) {
      showMsg("album-division-msg", result.message, false);
      document.getElementById("album-division-table").innerHTML = "";
      return;
    }

    showMsg("album-division-msg", result.message, true);

    console.log("Division frontend data:", result.data);

    document.getElementById("album-division-table").innerHTML = makeTable(
      result.data
    );
  } catch (err) {
    showMsg("album-division-msg", "Request failed: " + err.message, false);
    document.getElementById("album-division-table").innerHTML = "";
  }
}

loadDivisionAlbums();

async function loadAllPlaylists() {
  const res = await fetch("/playlists");
  const { data } = await res.json();
  document.getElementById("playlists-table").innerHTML = makeTable(
    data,
    ["NAME", "USERNAME", "LISTENS"],
    ["Playlist Name", "Owner", "Listens"],
  );
}

async function loadPlaylistsByUser() {
  const username = document.getElementById("search-username").value.trim();
  if (!username) return;
  const res = await fetch(`/playlists/${encodeURIComponent(username)}`);
  const { data } = await res.json();
  document.getElementById("user-playlists-table").innerHTML = makeTable(
    data,
    ["NAME", "USERNAME", "LISTENS"],
    ["Playlist Name", "Owner", "Listens"],
  );
}

async function loadPlaylistSongs() {
  const username = document.getElementById("pl-username").value.trim();
  const playlistName = document.getElementById("pl-name").value.trim();

  if (!username || !playlistName) {
    showMsg("see-playlist-songs-msg", "Both fields are required.", false);
    return;
  }
  try {
    const res = await fetch(
      `/playlists/${encodeURIComponent(username)}/${encodeURIComponent(playlistName)}/songs`,
    );
    const result = await res.json();
    if (!result.success) {
      showMsg("see-playlist-songs-msg", result.message, false);
      document.getElementById("playlist-songs-table").innerHTML = "";
      return;
    }
    showMsg("see-playlist-songs-msg", result.message, true);
    document.getElementById("playlist-songs-table").innerHTML = makeTable(
      result.data,
      ["SID", "SONGNAME", "RELEASEYEAR", "LISTENS", "POPULARITY"],
      ["Song ID", "Song Name", "Year", "Listens", "Popularity"],
    );
  } catch {
    showMsg("see-playlist-songs-msg", "Request failed.", false);
  }
}

async function searchSongsForAdd() {
  const query = document.getElementById('song-search').value.trim();
  if (!query) {
    document.getElementById('song-search-results').innerHTML = '';
    return;
  }
  const res = await fetch(`/songs/search?q=${encodeURIComponent(query)}`);
  const { data } = await res.json();
  if (!data || data.length === 0) {
    document.getElementById('song-search-results').innerHTML =
      '<p style="color:#666;font-size:0.85rem">No songs found.</p>';
    return;
  }
  document.getElementById('song-search-results').innerHTML =
    data.map(s =>
      `<button onclick="selectSong(${s.SID}, '${s.SONGNAME.replace(/'/g, "\\'")}')"
       style="display:block;width:100%;text-align:left;margin:2px 0;background:#1a1a1a;
              color:#ccc;border:1px solid #333;padding:6px 10px;border-radius:4px;cursor:pointer">
       ${s.SONGNAME} <span style="color:#666;font-size:0.8rem">(ID: ${s.SID})</span>
       </button>`
    ).join('');
}

function selectSong(sid, name) {
  document.getElementById('add-pl-sid').value = sid;
  document.getElementById('selected-song-display').textContent = `Selected: ${name}`;
  document.getElementById('song-search-results').innerHTML = '';
  document.getElementById('song-search').value = '';
}

async function addSongToPlaylist() {
  const username = document.getElementById("add-pl-username").value.trim();
  const playlistName = document.getElementById("add-pl-name").value.trim();
  const sid = document.getElementById("add-pl-sid").value.trim();

  if (!username || !playlistName || !sid) {
    showMsg("add-song-msg", "All fields are required.", false);
    return;
  }
  if (isNaN(parseInt(sid))) {
    showMsg("add-song-msg", "Song ID must be a number.", false);
    return;
  }
  try {
    const res = await fetch("/playlists/add-song", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, playlistName, sid: parseInt(sid) }),
    });
    const data = await res.json();
    showMsg("add-song-msg", data.message, data.success);
    if (data.success) {
      document.getElementById("pl-username").value = username;
      document.getElementById("pl-name").value = playlistName;
      loadPlaylistSongs();
    }
  } catch {
    showMsg("add-song-msg", "Request failed.", false);
  }
}

async function loadPlaylistsForDelete() {
  const username = document.getElementById("del-pl-username").value.trim();
  if (!username) {
    showMsg("delete-pl-msg", "Enter a username first.", false);
    return;
  }
  try {
    const res = await fetch(`/playlists/${encodeURIComponent(username)}`);
    const { data } = await res.json();
    if (!data || data.length === 0) {
      document.getElementById("delete-pl-list").innerHTML =
        '<p style="color:#666">No playlists found for that user.</p>';
      return;
    }
    document.getElementById("delete-pl-list").innerHTML =
      '<p style="color:#888;font-size:0.85rem">Click a playlist name to select it:</p>' +
      data
        .map(
          (p) =>
            `<button class="playlist-pick" onclick="document.getElementById('del-pl-name').value='${p.NAME}'"
                 style="margin:4px;background:#2a2a2a;color:#ccc;border:1px solid #444">
                 ${p.NAME} (${p.LISTENS} listens)</button>`,
        )
        .join("");
  } catch {
    showMsg("delete-pl-msg", "Request failed.", false);
  }
}

async function deletePlaylist() {
  const username = document.getElementById("del-pl-username").value.trim();
  const playlistName = document.getElementById("del-pl-name").value.trim();

  if (!username || !playlistName) {
    showMsg("delete-pl-msg", "Both fields are required.", false);
    return;
  }

  if (
    !confirm(
      `Are you sure you want to delete "${playlistName}"? This cannot be undone.`,
    )
  )
    return;

  try {
    const res = await fetch("/playlists/delete", {
      method: "DELETE",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, playlistName }),
    });
    const data = await res.json();
    showMsg("delete-pl-msg", data.message, data.success);
    if (data.success) loadAllPlaylists();
    loadPlaylistsByUser();
  } catch {
    showMsg("delete-pl-msg", "Request failed.", false);
  }
}

async function searchSongsByArtist() {
  const artistName = document
    .getElementById("artist-search-input")
    .value.trim();

  if (!artistName) {
    showMsg("artist-search-msg", "Please enter an artist name.", false);
    return;
  }

  try {
    const res = await fetch(
      `/songs/by-artist/${encodeURIComponent(artistName)}`,
    );
    const result = await res.json();
    if (!result.success) {
      showMsg("artist-search-msg", result.message, false);
      document.getElementById("artist-search-table").innerHTML = "";
      return;
    }
    showMsg("artist-search-msg", result.message, true);
    document.getElementById("artist-search-table").innerHTML = makeTable(
      result.data,
      [
        "ARTISTNAME",
        "SONGNAME",
        "RELEASEYEAR",
        "LISTENS",
        "ALBUMNAME",
        "GENRENAME",
      ],
      ["Artist", "Song Name", "Year", "Listens", "Album", "Genre"],
    );
  } catch {
    showMsg("artist-search-msg", "Request failed.", false);
  }
}

async function loadNationalityPopularity() {
  const res = await fetch("/nationality-popularity");
  const { data } = await res.json();
  document.getElementById("nationality-popularity-table").innerHTML = makeTable(
    data,
    ["NATIONALITY", "TOTALLISTENSHRS"],
    ["Nationality", "Total Listen Hours"],
  );
}

async function loadGenrePopularity() {
  const minSongInput = document.getElementById("genre-min-songs");
  const minSong = parseInt(minSongInput.value);
  const res = await fetch(`/genre-popularity/${minSong}`);
  const { data } = await res.json();
  document.getElementById("genre-popularity-table").innerHTML = makeTable(
    data,
    ["GENRENAME", "TOTALSONGS", "AVGLISTENS"],
    ["Genre", "Total Songs", "Avg Listens"],
  );
}

async function loadArtistPopularity() {
  const minListensInput = document.getElementById("artist-min-listens");
  const minListens = parseInt(minListensInput.value);
  const res = await fetch(`/artist-popularity/${minListens}`);
  const { data } = await res.json();
  document.getElementById("artist-popularity-table").innerHTML = makeTable(
    data,
    ["ARTISTNAME", "TOTALLISTENS", "MOSTLISTENED", "PERCENTLISTENED"],
    ["Artist", "Total Listens", "Most Listened Song", "% of Total"],
  );
}

async function loadTopGenre() {
  const res = await fetch("/top-genre");
  const { data } = await res.json();
  document.getElementById("top-genre-table").innerHTML = makeTable(
    data,
    ["GENRENAME", "AVGLISTENS"],
    ["Genre", "Avg Listens"],
  );
}

async function loadCollaboratedSongs() {
  const res = await fetch("/collaborated-songs");
  const { data } = await res.json();
  document.getElementById("collaborated-songs-table").innerHTML = makeTable(
    data,
    ["SONGNAME", "ARTISTCOUNT"],
    ["Song Name", "Number of Artists"],
  );
}

async function loadActiveUsers() {
  const res = await fetch("/active-users");
  const { data } = await res.json();
  document.getElementById("active-users-table").innerHTML = makeTable(
    data,
    ["USERNAME", "SUBSCRIPTION_TIER", "TOTALSONGS"],
    ["Username", "Tier", "Total Songs in Playlists"],
  );
}

async function loadUnplayedSongs() {
  const res = await fetch("/unplayed-songs");
  const { data } = await res.json();
  document.getElementById("unplayed-songs-table").innerHTML = makeTable(
    data,
    ["SID", "SONGNAME", "POPULARITY"],
    ["Song ID", "Song Name", "Popularity"],
  );
}

// These are autoload
loadNationalityPopularity();
loadGenrePopularity();
loadArtistPopularity();

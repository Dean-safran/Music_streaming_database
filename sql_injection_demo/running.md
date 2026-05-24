### `RUNNING.md`

```md
# RUNNING

First, start the music streaming app:

```bash
node server.js
```

Then, in another terminal, run 

```bash
make run
```

Output interpretation 
---------------------
The normal search returned 1 result because it searched only for "Video Games", the 
incredible song by our lord and savior lana del rey.

The SQL injection search returned 53 results because we inputted SQL such 
that in the where clause, where our user typed code was injected,
the condition is always true: '1'='1'.

This shows the vulnerable query is treating user input as SQL code, not just text.

Output
------
=== Normal search ===
{
  "success": true,
  "message": "1 result(s) found.",
  "data": [
    {
      "SID": 106,
      "SONGNAME": "Video Games",
      "RELEASEYEAR": 2012,
      "LISTENS": 2780000
    }
  ]
}

=== SQL injection search ===
{
  "success": true,
  "message": "53 result(s) found.",
  "data": [
    {
      "SID": 0,
      "SONGNAME": "Foggy Mountain Breakdown",
      "RELEASEYEAR": 1961,
      "LISTENS": 870000
    }
  ]
}
```
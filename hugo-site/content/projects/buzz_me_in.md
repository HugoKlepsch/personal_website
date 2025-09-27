---
date: '2025-09-27T10:02:11-04:00'
draft: false
title: 'Buzz Me In'
---

## Building Buzz: A Lightweight Multiplayer Quiz Buzzer

My side projects often almost always stem from a real-world problem I encounter.

In this case, it was trivia night.

My group of friends used to participate in [Reach for the top](https://en.wikipedia.org/wiki/Reach_for_the_Top),
a "Canadian trivia based academic quiz competition for high school students".
In those games, we always had a physical buzzer system, which usually looked 
like it was from the same vintage as the show itself (60s-80s). The buzzer 
system looked like a spider: There was a central box with a button, and several 
smaller boxes that had a button and a light. When the button of any smaller 
boxes was pressed, the central box would buzz and the light for that controller 
would turn on, indicating that the holder of that controller was the first to 
request to answer.

Fast-forward many years, my group of friends and I went our separate ways, but 
the desire for trivia night still remained. We no longer lived in the same 
town, so the buzzer system would have to be adapted to work on the internet.
Setting up voice communication was easy enough (discord, zoom, etc.), but 
keeping track of who buzzed first was a nightmare. Everyone swears they were 
faster. Everyone’s voice overlaps. Arguments ensue.

Enter [**Buzz**](https://buzz.hugo-klepsch.tech/), a re-imagining of that
original buzzer system.
I wanted a dead-simple way for players to buzz in while the buzz system keeps 
track of the order. No logins, accounts, emails; no overengineering. 

Just a web page, a button, and instant feedback.

→ Try it here on the public instance: [buzz.hugo-klepsch.tech](https://buzz.hugo-klepsch.tech/)

### A typical quiz night use case

* A host creates a game.
* Players join via the game ID.
* Each player can **Buzz**.
* The server tracks who buzzed first (and second, and third...).
* The host can clear the buzzes or advance the question number.

### Implementation

I challenged myself to build this with **just the Python standard library**.
No Flask, no Django, no jinja. There isn't even a requirements.txt file in the 
repo. At its core is Python’s built-in `http.server` module.

Buzz is implemented in just one file, [`buzz.py`](https://buzz.hugo-klepsch.tech/buzz.py), 
which implements both the UI and the JSON API.

The server uses the basic `http.server.BaseHTTPRequestHandler`, which is 
single-threaded, to handle HTTP requests. In the future, I may switch this to 
the threaded base class for better performance, but first I would have to 
synchronize access to the global state object.

#### The data model

The state for each game is stored in a global `GAMES` dictionary:

```python
GAMES = {
    "<game_id>": {
        "q": 1,        # current question number
        "ps": {        # players
            "<player_session_key>": {
                "username": "<player_name>",
                "is_creator": False 
            },
            # ...
        },   
        "b_ord": []    # buzz order, references player session keys if buzzed
    }
}
```

When someone hits **Buzz**, their session key is added to the game’s buzz order. 
When the host clears, that list resets.

#### The API

Buzz exposes a small API surface:

* `GET /` → Landing page (create or join a game)
* `GET /g/{GAME_ID}` → Game page
* `GET /a/s/{GAME_ID}` → Game status (JSON)
    - Response schema:
        ```yaml
        {
            "q": 1,                  # current question number
            "p": [
                {
                    "u": "<username>",
                    "c": false,
                    "b_o": 1
                },
                {
                    "u": "<username>",
                    "c": false,
                    "b_o": -1        # -1 if not buzzed
                },
                {
                    "u": "<username>",
                    "c": true,
                    "b_o": 0         # 0 if first to buzz
                }
            ]
        }
        ```
* `POST /create` → Create a game. Get a session key.
* `POST /join` → Join a game. Get a session key.
* `POST /a/b/{GAME_ID}` → Buzz in. Needs a session key.
* `POST /a/c/{GAME_ID}` → Clear buzzes (host only). Needs a session key.
* `POST /a/q/{GAME_ID}` → Set question number (host only). Needs a session key.

Each player has a unique session key (stored as a cookie), which ties their
username to their actions. The session key is generated when a player joins or 
creates a game and is never repeated, so you can't get other players' session 
key by joining again with their name.

The status API was designed to be minimal and fast, which is why it uses short 
JSON field names.

#### The UI

I didn’t want React or heavy JS. The front-end is a single HTML document 
(embedded CSS and JS) that polls the `/a/s/{GAME_ID}` endpoint periodically to 
refresh state. UI actions like buzzing, clearing, and setting the question 
number also trigger a state refresh. As a result, the UI feels responsive.

One feature I like is that users can join by pasting the game page link into 
their browser, even without joining the game via the landing page. The game page 
detects that the user is joining via a link and asks the user to pick a name.
It then joins for the user and redirects to the game page.

Game IDs are case-insensitive to make it easier to share IDs over voice chat.

If you have eyes, I'm sorry. It’s not going to win any awards for design, but 
it’s simple, lightweight, and responsive enough for the purpose.

### Deployment

Buzz can be run anywhere that Python 3 is installed.

```bash
$ python3 buzz.py -h
usage: buzz.py [-h] [--host HOST] [--port PORT]

Run the Buzz server

options:
  -h, --help   show this help message and exit
  --host HOST  Host interface to bind to (default: empty string = all interfaces. "::" for all IPv6, "0.0.0.0" for all IPv4, "localhost" for only localhost)
  --port PORT  Port to listen on (default: 8080)
  
$ python3 buzz.py # runs on 0.0.0.0:8080
```

Buzz is also packaged with Docker for easy deployment.

```bash
docker-compose up -d
```

If you want it to run as a systemd service, I included a small helper script 
that generates a systemd service file. 

### Lessons Learned

* **Simplicity pays off / Supply chain independence.** Using Python’s standard 
library was easier than I expected, and it was great not having to worry about 
installing, trusting and maintaining dependencies, especially given [recent](https://www.aikido.dev/blog/s1ngularity-nx-attackers-strike-again)
[and](https://en.wikipedia.org/wiki/XZ_Utils_backdoor) 
[past](https://www.aikido.dev/blog/popular-nx-packages-compromised-on-npm) 
[events](https://en.wikipedia.org/wiki/Npm_left-pad_incident).
* **Python is a great language for small projects.** I was able to put the
server in one file. It’s readable and easy to tweak.
* **State management is easy.** With no database, everything lives in memory. 
This is great for a simple use case like this and also simplifies testing, 
deployment, maintenance...
* **Polling is underrated.** Yes, I could have used WebSockets, and certainly this
would ease the load on my server, but for this use case, polling is *plenty* 
responsive—and I didn't need to learn anything new or worry about reconnecting 
logic.
* **Plain HTML looks good enough.** The default style is timeless.

Buzz has solved the problem it set out to tackle: settling quiz night disputes once and for all.

---

If you want to self-host or hack on it, the code is up on [GitHub](https://github.com/HugoKlepsch/buzz)
and runs with Python 3. Clone, run, and buzz away! It also has a systemd service 
file for easy deployment with docker compose.


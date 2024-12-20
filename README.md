# minecraft-server-docker

This is a minimal way to run a Minecraft server inside a Docker container with graceful shutdown support.

It requires you to bring your own server `.jar` and manage the server just like you would outside of Docker. If you're looking for a way to manage your server through `docker-compose.yml`, check out https://github.com/itzg/docker-minecraft-server.

## How to run

1. Clone this repository:

```bash
git clone https://github.com/nylyk/minecraft-server-docker.git
cd minecraft-server-docker
```

2. Place your server `.jar` into the `data` folder. (e.g., `data/server.jar`)
3. Adjust the options in `docker-compose.yml` according to the comments in the file.
4. Start the server with:

```bash
docker compose up -d
```

5. Manage your server in the `data` folder. (e.g., change `server.properties`, add mods, ...)
6. That's it!

## Restarting/stopping the server

To restart, stop or start the server use:

```bash
docker restart <container_name>
docker stop <container_name>
docker start <container_name>
```

Restart and stop will send the `STOP_COMMAND` to the server to stop it gracefully.

Important: If you make changes in `docker-compose.yml`, you need to reapply them by running `docker compose up -d` in the same directory.

## Accessing the server console

You can attach to the server console with `docker attach <container_name>`.

Alternatively, you can use the included `attach.sh` script which shows previous logs and reattaches when the server restarts:

```bash
./attach.sh <container_name>
```

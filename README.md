# LifeData Visualizer

## Configure
1. Change values in `.env` to your preference.
2. Create `$LDV_SOURCE_GRAPH_DIR` (Default `./mountpoints/graphs`)
3. Give write access to user with UID `$LDV_UID` or group with GID `$LDV_GID`. For example:

	```bash
		$ sudo chown "$USER:1001" ./mountpoints/graphs
		$ sudo chmod g+w ./mountpoints/graphs
	```

## Start
`docker-compose up --build --detach`

## Stop
`docker-compose stop`

## Limit resources
Add the following to `docker-compose.yml`:

```
  deploy:
    resources:
      limits:
        cpus: '1.0'
        memory: 1G
```

Run with `docker-compose --compatibility up --build --detach`

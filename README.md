# LifeData Visualizer

## Configure
1. Change values in `.env` to your preference.
2. Create `$LDV_GENERATOR_SOURCE_GRAPH_DIR` (Default `./mountpoints/dist/graphs`)
3. Give write access to user with UID `$LDV_GENERATOR_UID` or group with GID 
`$LDV_GENERATOR_GID`. For example:

	```bash
		$ sudo chown "$USER:1001" ./mountpoints/dist/graphs
		$ sudo chmod g+w ./mountpoints/dist/graphs
	```
4. Copy `.web-server/config/mini_httpd.conf.template` to `.web-server/config/mini_httpd.conf` and edit it with values specified in `.env`. For example, for default `.env` values:

	```
	nochroot
	dir=/srv/www/lifedata-visualizer
	user=lvdsrv
	host=0.0.0.0
	port=8080
	```

5. Add some data to `./mountpoints/data/sleep.csv` in the format:

	```
	Day,Fell asleep,Woke up
	2019-12-24,2019-12-24T23:00,2019-12-25T06:00
	...
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

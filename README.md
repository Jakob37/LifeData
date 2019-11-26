# LifeData Visualizer

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

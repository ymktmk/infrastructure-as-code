## sns-lambda-ses

## Go Build

```
GOARCH=amd64 GOOS=linux go build -ldflags="-s -w" -o bin/email_sender email_sender/main.go
```

# Deploy

```
sls deploy --stage dev
```

```
sls invoke -f <function_name>
```

```
sls remove --stage dev
```

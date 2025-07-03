# Hephaestus

## Install

All actions start from the root directory of the project

### Docker image build

```
cd tfg_umbrella
docker build -f DockerfileGame . -t game:latest
```

### Run docker containers

```
docker compose up -d
```

### Initialize database

There are multiple tools for initializing a database, such us pgAdmin or the cli utilities for postgres, choose the one who suits you better. The database schema is located inside the database folder. Database username is admin, password is 1234 and the database name is gamedb.

### Run java chapters

```
cd stages
java -cp ./gson/gson-2.12.1.jar ./ChapterOne.java
```

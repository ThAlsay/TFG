# Hephaestus

## Install

All actions start from the root directory of the project

### Docker image build

```bash
cd tfg_umbrella
docker build -f DockerfileGame . -t game:latest
docker build -f DockerfileEngine . -t engine:latest
```

### Run docker containers

In the project directory (where the docker files are located) execute:

```bash
docker compose up -d
```

### Initialize database

There are multiple tools for initializing a database, such us pgAdmin or the cli utilities for postgres, choose the one that suits you better. The database schema is located inside the database folder. Default database username is admin, password is 1234 and the database name is gamedb.

### Java communication with the game

All this command must be executed inside the "stages" folder

#### Initialize game

```bash
java -cp ./gson/gson-2.12.1.jar ./Utilities.java {start/save}
```

#### Run java chapters

```bash
java -cp ./gson/gson-2.12.1.jar ./Chapter{One/Two/Three/Four/Five}.java
```

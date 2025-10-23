# Hephaestus

The Hephaestus engine is a game engine writen in Elixir an designed to be used in games with a distributed architecture.
All this work is part of my degree final project and has not be tried in production.

As this is a educational project I don't have much experience with the language and the code might contain several bugs that the tests could not pick.

This repository also contains a game writen in Elixir using the engine as an example. It is desing for teaching second year computer engineering degree students about distributed systems. Therefore the comments are meant to guide said students.

## Repository contents

Right now this repository contains all my final project's documents and code.

### Document folder

The final project memory is located in this folder. All LaTex files, draw.io diagrams, images and the rest of related files necesary for compiling the memory into a PDF are in here.

### Tfg_umbrella folder

This folder is an elixir umbrella folder (hence the name) containing all the Elixir code for the engine and the game. It also contains the necesary Dockerfiles for building the images. One for the game with the engine and other for only the engine.

### Database folder

Contains the database initialization SQL script. This script initializes and dumps all the data necesary for running the game and the stages.

### Stages folder

All the Java code for teaching students about distributed systems is located in this folder.

### Manuals folder

Contains markdown files describing the lessons for the students.

### Docker compose files

Two docker compose files meant to start all the images necesary. The file with the "db" suffix only starts the database image for development. The other file starts all images as intended for simulating a distributed system without using other computers.

## Install

All actions start from the root directory of the project.

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

#### Start character and save game

```bash
java -cp ./gson/gson-2.12.1.jar ./Utilities.java {login/save} {tim/tom}
```

#### Run java examples and solutions

```bash
java -cp ./gson/gson-2.12.1.jar ./{java filename}.java
```

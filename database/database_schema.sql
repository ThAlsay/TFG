--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Debian 17.5-1.pgdg120+1)
-- Dumped by pg_dump version 17.1

-- Started on 2025-07-03 10:01:15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 24577)
-- Name: players; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.players (
    username character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    "character" jsonb NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.players OWNER TO admin;

--
-- TOC entry 218 (class 1259 OID 16419)
-- Name: saves; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.saves (
    user_name character varying(255) NOT NULL,
    safe jsonb NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.saves OWNER TO admin;

--
-- TOC entry 3364 (class 0 OID 24577)
-- Dependencies: 219
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.players VALUES ('prueba', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', '{"name": "prueba", "state": {"exp": 0, "arms": null, "body": null, "feet": null, "head": null, "legs": null, "level": 1, "health": 100, "weapon": null, "wisdom": 1, "charisma": 1, "missions": [], "strength": 1, "dexterity": 1, "in_combat": false, "inventory": [], "constitution": 1, "intelligence": 1, "current_location": "bosque"}}', '2025-05-15 13:38:25', '2025-07-02 16:08:11');


--
-- TOC entry 3363 (class 0 OID 16419)
-- Dependencies: 218
-- Data for Name: saves; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.saves VALUES ('prueba', '{"npcs": [], "enemies": [{"name": "goblin", "state": {"level": 1, "health": 4, "reward": 200, "wisdom": 0, "charisma": 4, "strength": 10, "dexterity": 30, "attack_type": "dexterity", "constitution": 2, "intelligence": 0}}, {"name": "mago_goblin", "state": {"level": 1, "health": 2, "reward": 300, "wisdom": 50, "charisma": 4, "strength": 2, "dexterity": 0, "attack_type": "wisdom", "constitution": 1, "intelligence": 4}}], "objects": [{"name": "espada", "state": {"stat": "strength", "type": "weapon", "level": 1, "value": 4}}], "locations": [{"name": "bosque", "state": {"npc": null, "enemy": [], "objects": [], "connections": ["entrada_cueva"]}}, {"name": "habitacion_cueva_1", "state": {"npc": null, "enemy": [], "objects": ["espada"], "connections": ["entrada_cueva", "corredor_cueva_1"]}}, {"name": "habitacion_cueva_2", "state": {"npc": null, "enemy": ["goblin", "mago_goblin"], "objects": [], "connections": ["corredor_cueva_1"]}}], "connections": [{"name": "entrada_cueva", "state": {"level": 1, "object": null, "location_1": "bosque", "location_2": "habitacion_cueva_1"}}, {"name": "corredor_cueva_1", "state": {"level": 1, "object": null, "location_1": "habitacion_cueva_1", "location_2": "habitacion_cueva_2"}}]}', '2025-05-15 13:38:25', '2025-07-02 16:08:11');
INSERT INTO public.saves VALUES ('initial', '{"npcs": [], "enemies": [{"name": "goblin", "state": {"level": 1, "health": 4, "reward": 200, "wisdom": 0, "charisma": 4, "strength": 10, "dexterity": 30, "attack_type": "dexterity", "constitution": 2, "intelligence": 0}}, {"name": "mago_goblin", "state": {"level": 1, "health": 2, "reward": 300, "wisdom": 50, "charisma": 4, "strength": 2, "dexterity": 0, "attack_type": "wisdom", "constitution": 1, "intelligence": 4}}], "objects": [{"name": "espada", "state": {"stat": "strength", "type": "weapon", "level": 1, "value": 4}}], "locations": [{"name": "bosque", "state": {"npc": null, "enemy": [], "objects": [], "connections": ["entrada_cueva"]}}, {"name": "habitacion_cueva_1", "state": {"npc": null, "enemy": [], "objects": ["espada"], "connections": ["entrada_cueva", "corredor_cueva_1"]}}, {"name": "habitacion_cueva_2", "state": {"npc": null, "enemy": ["goblin", "mago_goblin"], "objects": [], "connections": ["corredor_cueva_1"]}}], "connections": [{"name": "entrada_cueva", "state": {"level": 1, "object": null, "location_1": "bosque", "location_2": "habitacion_cueva_1"}}, {"name": "corredor_cueva_1", "state": {"level": 1, "object": null, "location_1": "habitacion_cueva_1", "location_2": "habitacion_cueva_2"}}]}', '2025-05-13 22:15:37', '2025-05-15 13:25:19');


--
-- TOC entry 3217 (class 2606 OID 24583)
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (username);


--
-- TOC entry 3215 (class 2606 OID 16425)
-- Name: saves saves_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.saves
    ADD CONSTRAINT saves_pkey PRIMARY KEY (user_name);


-- Completed on 2025-07-03 10:01:15

--
-- PostgreSQL database dump complete
--


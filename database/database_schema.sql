--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2 (Debian 17.2-1.pgdg120+1)
-- Dumped by pg_dump version 17.1

-- Started on 2025-10-24 23:35:52

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
    id character varying(255) NOT NULL,
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

INSERT INTO public.players VALUES ('distribuidos1', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', '{"name": "tim", "state": {"exp": 0, "arms": null, "body": null, "feet": null, "head": null, "legs": null, "level": 1, "health": 100, "weapon": null, "wisdom": 1, "charisma": 1, "missions": [], "strength": 1, "dexterity": 1, "in_combat": false, "inventory": [], "constitution": 1, "intelligence": 1, "current_location": "bosque"}}', '2025-05-15 13:38:25', '2025-10-22 22:06:14') ON CONFLICT DO NOTHING;
INSERT INTO public.players VALUES ('distribuidos2', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', '{"name": "tom", "state": {"exp": 0, "arms": null, "body": null, "feet": null, "head": null, "legs": null, "level": 1, "health": 100, "weapon": null, "wisdom": 1, "charisma": 1, "missions": [], "strength": 1, "dexterity": 1, "in_combat": false, "inventory": [], "constitution": 1, "intelligence": 1, "current_location": "bosque"}}', '2025-05-15 13:38:25', '2025-10-22 22:06:14') ON CONFLICT DO NOTHING;


--
-- TOC entry 3363 (class 0 OID 16419)
-- Dependencies: 218
-- Data for Name: saves; Type: TABLE DATA; Schema: public; Owner: admin
--

INSERT INTO public.saves VALUES ('initial', '{"npcs": [{"name": "sabio", "state": {"level": 1, "wisdom": 17, "charisma": 5, "strength": 1, "dexterity": 1, "interaction": "llave", "constitution": 1, "intelligence": 20, "interaction_limit": 5}}], "enemies": [{"name": "goblin", "state": {"level": 1, "health": 4, "reward": 200, "wisdom": 0, "charisma": 4, "strength": 10, "dexterity": 50, "attack_type": "dexterity", "constitution": 2, "intelligence": 0}}], "objects": [{"name": "espada", "state": {"stat": "strength", "type": "weapon", "level": 1, "value": 4}}, {"name": "llave", "state": {"stat": null, "type": "connection_object", "level": 1, "value": 0}}], "locations": [{"name": "bosque", "state": {"npc": null, "enemy": [], "objects": [], "connections": ["entrada_cueva"]}}, {"name": "habitacion_cueva_1", "state": {"npc": null, "enemy": [], "objects": ["espada"], "connections": ["entrada_cueva", "corredor_cueva_1", "corredor_cueva_2"]}}, {"name": "habitacion_cueva_2", "state": {"npc": null, "enemy": ["goblin"], "objects": [], "connections": ["corredor_cueva_1"]}}, {"name": "habitacion_cueva_3", "state": {"npc": "sabio", "enemy": [], "objects": [], "connections": ["corredor_cueva_2"]}}], "connections": [{"name": "entrada_cueva", "state": {"level": 1, "object": null, "location_1": "bosque", "location_2": "habitacion_cueva_1"}}, {"name": "corredor_cueva_1", "state": {"level": 1, "object": "llave", "location_1": "habitacion_cueva_1", "location_2": "habitacion_cueva_2"}}, {"name": "corredor_cueva_2", "state": {"level": 1, "object": null, "location_1": "habitacion_cueva_1", "location_2": "habitacion_cueva_3"}}]}', '2025-05-13 22:15:37', '2025-05-15 13:25:19') ON CONFLICT DO NOTHING;
INSERT INTO public.saves VALUES ('current', '{"npcs": [{"name": "sabio", "state": {"level": 1, "wisdom": 17, "charisma": 5, "strength": 1, "dexterity": 1, "interaction": "llave", "constitution": 1, "intelligence": 20, "interaction_limit": 5}}], "enemies": [{"name": "goblin", "state": {"level": 1, "health": 4, "reward": 200, "wisdom": 0, "charisma": 4, "strength": 10, "dexterity": 50, "attack_type": "dexterity", "constitution": 2, "intelligence": 0}}], "objects": [{"name": "espada", "state": {"stat": "strength", "type": "weapon", "level": 1, "value": 4}}, {"name": "llave", "state": {"stat": null, "type": "connection_object", "level": 1, "value": 0}}], "locations": [{"name": "bosque", "state": {"npc": null, "enemy": [], "objects": [], "connections": ["entrada_cueva"]}}, {"name": "habitacion_cueva_1", "state": {"npc": null, "enemy": [], "objects": ["espada"], "connections": ["entrada_cueva", "corredor_cueva_1", "corredor_cueva_2"]}}, {"name": "habitacion_cueva_2", "state": {"npc": null, "enemy": ["goblin"], "objects": [], "connections": ["corredor_cueva_1"]}}, {"name": "habitacion_cueva_3", "state": {"npc": "sabio", "enemy": [], "objects": [], "connections": ["corredor_cueva_2"]}}], "connections": [{"name": "entrada_cueva", "state": {"level": 1, "object": null, "location_1": "bosque", "location_2": "habitacion_cueva_1"}}, {"name": "corredor_cueva_1", "state": {"level": 1, "object": "llave", "location_1": "habitacion_cueva_1", "location_2": "habitacion_cueva_2"}}, {"name": "corredor_cueva_2", "state": {"level": 1, "object": null, "location_1": "habitacion_cueva_1", "location_2": "habitacion_cueva_3"}}]}', '2025-05-13 22:15:37', '2025-05-15 13:25:19') ON CONFLICT DO NOTHING;


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
    ADD CONSTRAINT saves_pkey PRIMARY KEY (id);


-- Completed on 2025-10-24 23:35:52

--
-- PostgreSQL database dump complete
--


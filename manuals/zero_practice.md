# Práctica 0

| Documento: | Módulo-0: Instalación                                                  |
| ---------- | ---------------------------------------------------------------------- |
| Curso:     | SISTEMAS DISTRIBUIDOS - Grado en Ingeniería Informática                |
| Libro:     | Enunciado 0: Instalación de las herramientas empleadas en la prácticas |
| Autor:     | SAYALERO BLAZQUEZ, ALONSO                                              |
| Fecha:     | martes, 4 de noviembre de 2025                                         |
| Versión:   | 0.1                                                                    |

## Tabla de contenidos

## Objetivos

Este documento es una guía para instalar todo lo que vamos a necesitar para poder realizar las siguientes prácticas.

## Docker

### Windows / MacOs / Linux (Docker Desktop)

En Windows y MacOs docker solo está disponible mediante Docker Desktop. Para instalarlo sigue las instrucciones oficiales: https://docs.docker.com/get-started/get-docker/

Existe también una versión para Linux, aunque si trabajas desde WSL hay que seguir las instrucciones del siguiente apartado.

### Linux (Docker Engine) / WSL

Este es el único método mediante el cuál podemos tener docker en WSL. Docker Engine instala únicamente los comandos por terminal sin aplicación de escritorio y solo
está disponible para Linux.

Al igual que con Docker Desktop, Docker proporciona instrucciones oficiales y detalladas sobre como instalarlo: https://docs.docker.com/engine/install/

## Java

Para programar en Java vamos a necesitar el JDK de Oracle, el cuál se puede descargar desde este enlace: https://www.oracle.com/es/java/technologies/downloads/#jdk25-linux

Si nos encontramos en Linux/WSL el enlace anterior contiene paquetes para Debian y derivados y RedHat y derivados (.deb y .rpm), pero el JDK se puede encontrar
normalmente en los repositorios de las distintas distribuciones. Esta suele ser una forma más sencilla de instalarlo.

## Elixir (Opcional)

La página web oficial de Elixir proporciona guías especificas para cada sistema operativo. https://elixir-lang.org/install.html

La descarga e instalación de elixir no es obligatoria y se puede realizar la práctica que lo involucra simplemente reconstruyendo la imagen de docker pertinente.

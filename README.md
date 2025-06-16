# 🛠 MEnv for Windows – Maven Version Manager

A simple tool inspired by [JEnv-for-Windows](https://github.com/FelixSelter/JEnv-for-Windows), designed to manage and switch between multiple installed **Maven** versions on Windows.

> Perfect for developers working on projects with different Maven version requirements.

## Getting Started

- Clone this repository
- Add it to the path
- Run mvn.bat

## Description

menv.ps1 support for switching between installed Maven versions.

added functions :

- menv-add
- menv-remove
- menv-change
- menv-getmvn

--- Defines the menv function with subcommands: ---

add — register a Maven version

list — show registered versions

remove — delete a registered version

change — switch to selected Maven version (updates PATH, MAVEN_HOME)

Saves configuration to menv.json
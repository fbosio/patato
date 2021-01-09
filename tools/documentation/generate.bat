@echo off
call ldoc .
echo Moving README to directory "engine"
move README.markdown ..\..\engine\README.md

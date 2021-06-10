Exports configured to go to:
./export/exe/ and ./export/html/
These are gitignored so you might have to create the directories yourself

To test web export:
cd ./export/html
python -m http.server 8000

and then go to:
localhost:8000/gmtk-jam.html

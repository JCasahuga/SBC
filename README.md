## Practica 2 IA (SBC)
Aquesta pràctica tracta de recomenar exercicis a majors de 65 anys en base a coneixement expert.

Per poder executar el programa necessitarem tenir instal·lat el owl2clips:
```
git clone https://github.com/bejar/owl2clips
pip3 install owl2clips
```
o alternativament:
```
git clone https://github.com/bejar/owl2else
pip3 install owl2else
```
Potser és necessari reiniciar la terminal.

Seguidament haurem de passar la ontologia al fitxer .clp (CLIPS):
```
owl2clips --input ontologia_sbc.owl --format turtle
```

Recorda que si no tens [clips](https://clipsrules.net/) serà necessari baixar i instal·lar-ho al ordinador. Seguidament ja podràs obrir clips:
```
clips
```
i escriure les següents línies per carregar la ontologia i el model 
```
(load "./ontologia_sbc.clp")
(load "./recomendador_sbc.clp")
(reset)
(run)
```
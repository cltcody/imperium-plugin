# Goldene Fixtures — humanize-Selbsttest (Deutsch)

Eval-Korpus für die deutsche Regelwerksschicht (`ai-tells-de.md`). Der
Selbsttest scannt **nur** den Abschnitt zwischen `## Planted fixtures` und
`## Answer key` (der Antwortschlüssel benennt die Muster; die ganze Datei zu
scannen produziert Falschtreffer auf der eigenen Dokumentation) — in eine
Scratch-Datei extrahieren, exakt wie im Selbsttest-Block von SKILL.md:

```bash
TARGETS="$(mktemp)"
sed -n '/^## Planted fixtures/,/^## Answer key/p' "$FIX" > "$TARGETS"
```

Die Urteilsschicht auf den extrahierten Abschnitt anwenden, **bevor** der
Antwortschlüssel gelesen wird — der Schlüssel ist das Bewertungsblatt, nicht
die Eingabe. **Abnahme:** jede Zeile des Antwortschlüssels wird erkannt —
Grep-Zeilen durch den deterministischen Scan, Urteilszeilen durch die
Umschreibpassage — und der Kontrollabsatz erzeugt null Treffer beider Art.
Pro Zeile bestehen/durchgefallen berichten, jeden Fehltreffer benennen.

## Planted fixtures

### P1: lexikalische Schicht

In der heutigen schnelllebigen Welt des globalen Handels müssen Teams
in die Welt der Zollvorschriften eintauchen. Unsere Plattform verfolgt einen
ganzheitlichen Ansatz, bietet eine breite Palette an Automatisierungen, um
Zollanmeldungen nahtlos abzuwickeln und das volle Potenzial Ihrer
Compliance-Daten zu entfalten.

### P2: Interpunktionsschicht

Die Migration lief über Nacht — niemand wurde alarmiert. Das neue Schema —
ausgelegt auf Lesezugriffe aus mehreren Regionen — halbierte die
Abfragezeiten, und das Team — ohnehin knapp besetzt — schätzte den leisen
Start.

### P3: Strukturschicht

Das ist nicht nur ein Berichtswerkzeug, sondern eine strategische
Kommandozentrale. Es ist schnell, flexibel und zuverlässig. Jeder Beteiligte
kann finden, was er braucht, umsetzen, was er findet, und teilen, was er
lernt. Das Ergebnis: weniger Meetings und schnellere Entscheidungen.
Zusammenfassend lässt sich sagen, dass die Plattform Ihr Team optimal
aufstellt.

### P4: Floskeln und Hedges

Das Archiv legt Zeugnis ab von der Innovationskraft des Unternehmens und ist
eine wahre Fundgrube, die unter Umständen möglicherweise etwas nützliche
Einblicke für Prüfer bieten könnte. Es ist wichtig zu beachten, dass diese
Unterlagen eine entscheidende Rolle in Compliance-Prüfungen spielen.

### Kontrolle: sauberer menschlicher Registerabsatz (muss null Treffer erzeugen)

Der Exportjob läuft um 02:00 UTC und schreibt pro Region eine CSV-Datei in
den Backup-Bucket. Jede Datei enthält höchstens 50.000 Zeilen. Schlägt eine
Prüfsumme fehl, versucht der Job es zweimal erneut, bricht dann ab und
alarmiert den Bereitschaftsdienst. Im letzten Monat gab es zwei Ausfälle,
beide durch einen abgelaufenen Service-Account-Schlüssel; das
Rotationsskript wurde noch in derselben Woche korrigiert.

## Answer key

| # | Gepflanztes Muster | Absatz | Schicht | Erkannt durch |
|---|--------------------|--------|---------|---------------|
| 1 | „In der heutigen schnelllebigen Welt" | P1 | lexikalisch | grep |
| 2 | „in die Welt der … eintauchen" | P1 | lexikalisch | grep |
| 3 | „ganzheitlichen Ansatz" | P1 | lexikalisch | grep |
| 4 | „breite Palette an" | P1 | lexikalisch | grep |
| 5 | „nahtlos" | P1 | lexikalisch | grep |
| 6 | „das volle Potenzial … zu entfalten" | P1 | lexikalisch | grep |
| 7 | Geviertstrich ×5 — einer einzeln + zwei paarige Einschübe | P2 | Interpunktion | grep |
| 8 | „nicht nur X, sondern Y" | P3 | strukturell | grep |
| 9 | Dreierreihung: „schnell, flexibel und zuverlässig" | P3 | strukturell | Urteil |
| 10 | Dreierreihung: „finden / umsetzen / teilen" | P3 | strukturell | Urteil |
| 11 | Doppelpunkt-Fazit: „Das Ergebnis: …" | P3 | strukturell | Urteil |
| 12 | Aufsatz-Schluss: „Zusammenfassend lässt sich sagen …" | P3 | strukturell/lexikalisch | grep |
| 13 | „legt Zeugnis ab von" | P4 | Floskel | grep |
| 14 | „wahre Fundgrube" | P4 | Floskel | grep |
| 15 | Hedge-Stapel: „unter Umständen möglicherweise etwas … könnte" | P4 | strukturell | Urteil |
| 16 | „Es ist wichtig zu beachten" | P4 | lexikalisch | grep |
| 17 | „eine entscheidende Rolle … spielen" | P4 | lexikalisch | grep |
| Ktrl | Kontrollabsatz | Kontrolle | — | muss null Treffer sein |

# KI-Muster-Regelwerk (Deutsch)

Das deutsche Gegenstück zu `ai-tells.md`. Gleiche drei Schichten: lexikalisch
(grep-erkennbare Wörter/Phrasen), Interpunktion (grep-erkennbar), strukturell
(Urteil — Vorher/Nachher-Umschreibungen). Der Ablauf in SKILL.md gilt
unverändert; nur der Katalog ist ein anderer.

**Quellen und Belastbarkeit:** Für Deutsch existiert (Stand Prüfdatum) keine
Exzess-Vokabular-Studie vom Rang Kobak et al. 2025. Dieser Katalog ist v1:
die strukturellen Muster des englischen Regelwerks (Dreierreihung,
„nicht nur X, sondern Y", Hedge-Stapel, Aufsatz-Schluss) übertragen sich
direkt, da sie sprachunabhängig im Modellverhalten liegen; die lexikalische
Liste besteht aus den etablierten deutschen Entsprechungen der katalogisierten
englischen Marker plus in deutscher LLM-Ausgabe wiederkehrenden Füllphrasen.
Sie ist damit schwächer extern validiert als die englische Liste — Treffer
noch bewusster als *Kandidaten* behandeln, nicht als automatische Streichung.

**Versionierung:** Marker variieren je Modell und Domäne — Liste und
Grep-Block immer zusammen pflegen, danach den Selbsttest gegen
`fixtures-de.md` laufen lassen. **Zuletzt geprüft: 2026-07-03.**

---

## Die Grep-Einzeiler (ausführen, nicht paraphrasieren)

```bash
# TARGETS = die zu prüfenden Prosadateien, als einzeln gequotete Dateinamen
# (niemals die Quellen des dieses cc-Plugins eigene Command-/Skill-Quellen, außer
# ausdrücklich beauftragt).
: "${TARGETS:?set TARGETS to the prose files under review first}"

# Interpunktionsschicht — Geviertstrich (em dash, U+2014). In deutscher
# Typografie ist der Gedankenstrich der Halbgeviertstrich „–" mit Leerzeichen;
# ein „—" ist im Deutschen fast immer ein KI-Artefakt.
grep -n -- '—' $TARGETS

# Lexikalische Schicht — KI-Standardvokabular und -phrasen (case-insensitiv)
grep -niE -- 'in der heutigen( schnelllebigen| digitalen)? (welt|zeit|geschäftswelt)|im digitalen zeitalter|es ist wichtig,? zu (beachten|betonen|erwähnen)|es sei (darauf hingewiesen|angemerkt)|zusammenfassend|abschließend lässt sich|(entscheidende|zentrale|schlüssel).?rolle|von entscheidender bedeutung|nahtlos|ganzheitlich|vielschichtig|facettenreich|tauchen sie ein|in die welt [^.]{0,60}(eintauch|einzutauchen)|eintauchen in die welt|näher beleuchte(n|t)|revolutionier|bahnbrechend|wahre fundgrube|schatztruhe|zeugnis (von|ab)|herzstück|pulsierend|eine vielzahl (von|an)|breite palette (an|von)|(wertvolle|spannende) einblicke|volle[sn]? potenzial|potenzial voll aus(zu)?schöpfen|auf ein neues level|auf die nächste stufe|komplexität(en)? (zu )?(meistern|navigieren)|(sich )?(ständig|stetig) (weiterentwickelnd|wandelnd)|game.?changer|hand in hand|ein absolutes muss' $TARGETS

# Strukturschicht, grep-erkennbarer Teil — „nicht nur X, sondern (auch) Y"
grep -niE -- '(nicht nur|nicht bloß) [^.]{3,80}, sondern( auch| vielmehr)?' $TARGETS
```

**Zeilenumbruch-Vorbehalt:** wie im englischen Regelwerk — die Greps sind
zeilenbasiert; in hart umbrochenem Markdown kann eine Mehrwortphrase („volles
Potenzial entfalten") über den Umbruch rutschen. Vorher entwrappen
(`fold -s -w 10000` bzw. absatzweise zusammenfügen) oder die Urteilsschicht
als Auffangnetz nutzen.

Jeder Treffer ist ein *Kandidat*, keine automatische Streichung — „nahtlos"
kann in einer Textilbeschreibung wörtlich gemeint sein, „nicht nur …, sondern
auch" ist in juristischer Prosa oft präzise. Treffer auflisten, beurteilen,
umschreiben oder mit Begründung stehen lassen.

## Lexikalische Schicht — Wörter/Phrasen und Ersetzungen

Zeilen mit *(nur Urteil)* stehen nicht im Grep-Block — das nackte Wort ist zu
häufig für rauschfreies Greppen; in der Umschreibpassage abfangen.

| Muster | Ersetzen durch |
|--------|----------------|
| in der heutigen (schnelllebigen/digitalen) Welt/Zeit | Floskel streichen; mit dem Punkt beginnen |
| im digitalen Zeitalter | streichen |
| es ist wichtig zu beachten/betonen | streichen; der Satz überlebt ohne |
| es sei darauf hingewiesen | streichen oder direkt sagen |
| zusammenfassend (lässt sich sagen) | streichen; mit dem letzten inhaltlichen Punkt enden |
| abschließend lässt sich festhalten | streichen |
| entscheidende/zentrale/Schlüssel-Rolle (spielen) | sagen, was ohne es kaputtgeht |
| von entscheidender Bedeutung | wichtig — oder die Konsequenz nennen |
| maßgeblich *(nur Urteil)* | konkret machen oder streichen |
| nahtlos | die fehlende Reibung benennen („kein erneutes Anmelden nötig") |
| ganzheitlich | vollständig — oder aufzählen, was abgedeckt ist |
| vielschichtig / facettenreich | streichen; die Facetten zeigen |
| eintauchen (in die Welt von) / tauchen Sie ein | ansehen — oder einfach anfangen |
| (näher) beleuchten | untersuchen, beschreiben, zeigen |
| unterstreichen (figurativ) *(nur Urteil)* | zeigen, belegen |
| revolutionieren / bahnbrechend | sagen, was sich messbar ändert |
| Meilenstein *(nur Urteil)* | das konkrete Ergebnis nennen |
| wahre Fundgrube / Schatztruhe | viele; N Stück |
| Zeugnis von / legt Zeugnis ab | Beleg für — oder den Fakt schlicht nennen |
| Herzstück | Kern, zentraler Baustein — oder konkret benennen |
| pulsierend / lebendig *(lebendig: nur Urteil)* | konkretes Detail („40 Stände", „bis 2 Uhr geöffnet") |
| dynamisch / innovativ *(nur Urteil)* | streichen oder belegen |
| eine Vielzahl von/an | viele; die Zahl nennen |
| eine breite Palette an/von | aufzählen oder die Zahl nennen |
| wertvolle/spannende Einblicke | sagen, was man danach weiß |
| das volle Potenzial entfalten/ausschöpfen | den konkreten Gewinn nennen |
| auf ein neues Level / die nächste Stufe heben | die messbare Verbesserung nennen |
| die Komplexität meistern/navigieren | bewältigen, lösen — oder das Problem benennen |
| sich ständig/stetig weiterentwickelnd | ganze Floskel streichen |
| Game-Changer | sagen, was sich ändert, messbar |
| Hand in Hand (figurativ) | zusammen; oder den Mechanismus nennen |
| ein absolutes Muss | nötig, weil … — Grund statt Ausruf |
| darüber hinaus / des Weiteren *(nur Urteil, bei Häufung)* | außerdem, auch — oder Sätze verbinden |
| Fazit: (als Absatzauftakt) *(nur Urteil)* | streichen; siehe Aufsatz-Schluss |

## Interpunktionsschicht — Geviertstrich und Gedankenstrich-Häufung

Zwei Stufen:

1. **„—" (Geviertstrich) ist im Deutschen selbst das Muster.** Deutsche
   Typografie setzt als Gedankenstrich den Halbgeviertstrich „–" mit
   Leerzeichen; der englische Geviertstrich taucht fast nur in maschinell
   erzeugtem oder aus dem Englischen übernommenem Text auf. Jeder Treffer:
   umformen (Komma, Klammern, Punkt) oder — wo ein Gedankenstrich wirklich
   trägt — durch „ – " ersetzen.
2. **Auch korrekte „ – "-Einschübe zählen als Muster, wenn gehäuft** (mehrere
   pro Absatz): nur Urteil, kein Grep.

| Vorher | Nachher |
|--------|---------|
| Der Bericht — drei Wochen Arbeit — verpuffte. | Der Bericht, drei Wochen Arbeit, verpuffte. |
| Wir haben früh geliefert — niemand hat es gemerkt. | Wir haben früh geliefert. Niemand hat es gemerkt. |
| Der Fix — eine einzige Zeile — schloss das Ticket. | Der Fix (eine einzige Zeile) schloss das Ticket. |

## Strukturschicht — Urteil und Umschreibung

**Grundregel jeder Umschreibung: der Ersatzfakt muss aus dem Quelltext oder
vom Nutzer stammen.** Fehlt er: Floskel streichen oder nachfragen — niemals
Zahlen, Dauern oder Details erfinden. Die konkreten Werte in den
Nachher-Beispielen sind Platzhalter, keine Vorlagen.

**Nicht nur X, sondern (auch) Y**
- Vorher: *Das ist nicht nur ein Dashboard, sondern eine Kommandozentrale für das ganze Team.*
- Nachher: *Das Dashboard zeigt die offenen Aufgaben aller Teammitglieder auf einem Bildschirm.*

**Dreierreihung** — Adjektiv- oder Satzglied-Triaden als Füllrhythmus.
- Vorher: *Der neue Ablauf ist schnell, flexibel und zuverlässig.*
- Nachher: *Der neue Ablauf lädt in unter einer Sekunde und ist seit einem Monat ohne Ausfall.*
- Eine Triade bleibt nur, wenn alle drei Glieder eigenen, nachprüfbaren Inhalt tragen.

**Hedge-Stapel** — gestapelte Abschwächungen, die die Aussage aufheben.
- Vorher: *Das könnte unter Umständen möglicherweise zu etwas langsameren Builds führen.*
- Nachher: *Bei kaltem Cache werden Builds langsamer, etwa 40 s statt 10 s.*
- Maximal eine ehrliche Einschränkung; besser: die Bedingung statt der Abschwächung.

**Aufsatz-Schluss / Abschnitts-Zusammenfassung** — ein Schlussabsatz, der das
Gesagte wiederholt („Zusammenfassend …", „Insgesamt …", „Fazit: …",
„Wenn Sie diese Schritte befolgen …").
- Umschreibung: streichen. Mit dem letzten inhaltlichen Punkt enden.

**Doppelpunkt-Fazit** — „Das Ergebnis: weniger Fehler." / „Die Erkenntnis: X."
- Vorher: *Wir haben den Parser neu geschrieben. Das Ergebnis: weniger Fehler und zufriedenere Nutzer.*
- Nachher: *Wir haben den Parser neu geschrieben, und die Fehlermeldungen haben sich halbiert.*

**Werbliche Floskeln** — „legt Zeugnis ab", „wahre Fundgrube", „spielt eine
entscheidende Rolle", „ein Leuchtturmprojekt".
- Umschreibung: durch einen nachprüfbaren Fakt *aus Quelltext oder Nutzer*
  ersetzen oder streichen. Eine erfundene Zahl ist schlimmer als die Floskel.

**Gleichförmiger Satzrhythmus** — jeder Satz 15–25 Wörter, gleicher
Subjekt-Prädikat-Objekt-Bau, eine Idee pro Satz. Kein Grep fängt das; den
Absatz (innerlich) laut lesen.
- Umschreibung: zwei kurze Sätze verbinden, einen langen teilen, einen Satz
  mit Nebensatz eröffnen. Sichtbare Varianz, keine Formel.

**Sie-Anrede-Marketington** *(deutschspezifisch, nur Urteil)* — durchgängige
imperativische Leseransprache in Sachprosa („Entdecken Sie …", „Profitieren
Sie von …", „Lassen Sie uns …").
- Vorher: *Entdecken Sie, wie Sie mit unserem Tool Ihre Prozesse optimieren.*
- Nachher: *Das Tool verkürzt die Freigabeschleife von fünf Tagen auf einen.*
- In echtem Marketingtext mit bewusster Leseransprache: stehen lassen, notieren.

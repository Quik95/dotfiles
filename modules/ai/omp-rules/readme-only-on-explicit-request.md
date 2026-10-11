---
name: readme-only-on-explicit-request
description: "Nie zmieniaj README bez wyraźnego polecenia użytkownika."
condition: "[\\s\\S]+"
scope: ["tool:edit(**/README.md)", "tool:write(**/README.md)"]
---

Nie aktualizuj `README.md`, chyba że użytkownik wyraźnie polecił jego zmianę w bieżącej rozmowie. Instalacja, konfiguracja lub zmiana funkcjonalności nie stanowi takiego polecenia. Ogólny wymóg aktualizacji dokumentacji nie upoważnia do edycji README; informacje o zmianie i użyciu podaj w odpowiedzi.
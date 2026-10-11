---
name: check-nix-options-before-file-management
description: "Przed proponowaniem ręcznego zarządzania plikami sprawdź dedykowane opcje NixOS lub Home Manager."
condition: "home\\.file\\s*\\.\\s*\""
scope: "text"
---

Przed zaproponowaniem `home.file` sprawdź moduł używany przez projekt i dostępne dedykowane opcje NixOS lub Home Manager dla danego programu. Preferuj dedykowaną opcję, jeśli obsługuje wymagane zachowanie. Dopiero po potwierdzeniu braku takiej opcji proponuj zarządzanie plikiem przez `home.file`; podaj krótko, jaki moduł sprawdzono i czego w nim brakuje. Nie zakładaj braku opcji na podstawie pamięci ani istniejącej konfiguracji.
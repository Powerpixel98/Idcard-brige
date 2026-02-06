Author
greenarrov

idcard_bridge

idcard_bridge ist eine Erweiterung für jsfour-idcard, die es ermöglicht, Ausweise über ox_inventory zu benutzen und diese selbst anzusehen oder anderen Spielern zu zeigen – inklusive ox_lib Menü, Animation und Target-Auswahl.

✨ Features

📇 Personalausweis, Führerschein & Waffenschein als Items

🧭 ox_lib Menü: Ansehen / Zeigen

👤 „Zeigen“ an nächsten Spieler mit Marker

🚗 Zeigen auch aus dem Fahrzeug (nur Fahrer/Beifahrer)

🪪 Animation mit Clipboard (laufbar)

🔒 Serverseitige Checks (Item, Distanz)

⚡ ESX + ox_inventory kompatibel

📦 Voraussetzungen
ESX
ox_inventory
ox_lib
jsfour-idcard
esx_license
oxmysql

🛠 Installation

Resource in deinen resources Ordner legen:

idcard_bridge


server.cfg:

ensure ox_lib
ensure ox_inventory
ensure jsfour-idcard
ensure idcard_bridge


In fxmanifest.lua sicherstellen:

shared_scripts { '@ox_lib/init.lua' }


Items in ox_inventory anlegen (siehe Beispiel im Code).

▶️ Nutzung

Item benutzen → Menü öffnet sich

Ansehen: Du siehst deinen Ausweis

Zeigen: Nächster Spieler sieht deinen Ausweis

Bestätigen: E / ENTER

Abbrechen: ESC / BACKSPACE

🧠 Hinweise

„Zeigen“ im Fahrzeug nur als Fahrer oder Beifahrer

Reichweite im Fahrzeug erhöht (Fenster zeigen)

Animation stoppt automatisch nach Nutzung

📄 Lizenz

Free to use – kein Reupload ohne Credits.

❤️ Credits
greenarrov

jsfour-idcard

ox_lib

ox_inventory

ESX Framework

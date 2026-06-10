# 🪙 Loot Zero

App financeiro de **Orçamento Base Zero (ZBB)** com estética **16-bit RPG/aventura** — identidade visual original, inspirada (não derivada) na era SNES.

## Cosmologia
- 🏯 **A Cidadela** — Sua grande meta de fim de ano (ex: R$ 10.000).
- 🎁 **Baú Curinga** — Fundo YOLO (gastos impulsivos). Tem um raio ⚡ na fechadura.
- 🚪 **Portal de Entrada** — Inbox de transações vindas do Open Finance.
- 🧙 **Zero** — Mascote-guardião do tesouro. Avisa quando você fura o orçamento.

## Stack
- **Flutter** + **Riverpod** (estado) + **go_router** (navegação)
- **Isar** (cache local)
- **Supabase** (auth + Edge Functions para Open Finance via Pluggy/Belvo)
- **google_fonts** (Press Start 2P + VT323)

## Setup
```powershell
cd "C:\Users\Samuel Heimbach\Desktop\LootZero"
flutter create . --project-name loot_zero --org com.lootzero --platforms=android,ios
flutter pub get
flutter run
```

## Paleta
Cores chapadas, alta saturação, sem gradientes:
- **Verde Esmeralda** — sucesso, metas.
- **Ouro Moeda** — saldo disponível.
- **Vermelho Rubi** — déficit/alerta.
- **Roxo Real** — acento da marca, mascote.
- **Pedra de Cidadela** — neutros sólidos.

## Estrutura
`lib/core` (theme, widgets, haptics) — `lib/domain` (entidades + ZBB) — `lib/data` (Isar + Supabase) — `lib/features` (telas).

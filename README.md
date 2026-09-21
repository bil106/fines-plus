# Fines+

Flutter-застосунок для автовласників в Україні: перевірка й оплата штрафів, облік витрат на авто (паливо, ТО, страхування), нагадування про дедлайни, кілька авто в одному гаражі. Один код живить кілька білих брендів (white-label) під різні ринки.

Правила розробки, архітектура дизайн-системи, локалізації, state management і git-конвенції — повністю в **[`CLAUDE.md`](./CLAUDE.md)**, тут не дублюються.

## Ідея

Базовий сценарій: власник авто хоче в одному місці бачити, чи є неоплачені штрафи, коли наступне ТО чи закінчується страховка, і скільки він реально витрачає на машину (включно з точним розрахунком витрати пального). Штрафи перевіряються автоматично через офіційний сайт МВС (не капчу/скрапінг третіх сторін — стара реалізація з капчею прибрана, див. `git log --grep="captcha"`), решта — це трекер витрат з нагадуваннями.

Другий шар ідеї — **white-label**: та сама кодова база вже налаштована як 5 окремих продуктів/брендів (`assets/config/*.json`), кожен зі своїм кольором, шрифтом, ринком і набором фіч (наприклад, перевірка штрафів вимкнена для ринків поза Україною). Детально — [`docs/white-label-playbook.md`](./docs/white-label-playbook.md).

## Можливості

- **Штрафи** (`lib/features/fines`, `lib/features/history`, `lib/backend`) — автоперевірка через офіційний сайт МВС, кулдаун між перевірками, тижневе нагадування, зведення нових штрафів.
- **Гараж** (`lib/features/vehicle`) — кілька авто, картка авто (назва/номер/пробіг), статус-чіп ОК/ТО/страховка, дані авто за номером.
- **Витрати** (`lib/features/expenses`, `lib/features/maintenance`) — заправка (з перемикачем "повний бак" для точного розрахунку витрати л/100км, дивись `lib/core/extensions/fuel_calculator.dart`), ТО, мийка, тюнінг, шини, акумулятор, олива.
- **Нагадування** (`lib/features/reminders`) — заплановані сервіси та закінчення страховки.
- **Статистика й аналітика** (`lib/features/statistics`, `lib/features/analytics`) — витрати по категоріях, UAH/км, л/100км.
- **Експорт** (`lib/features/export`) — PDF-звіт для покупця авто, Excel.
- **Підписка** (`lib/features/subscription`) — квартальний і річний план, 7-денний тріал, нативний білінг стору (`in_app_purchase`).
- **Реєстрація** (`lib/features/registration`) — email, Google, Apple, Facebook.
- **Онбординг** (`lib/presentation/screens/onboarding_screen.dart`) — 4 екрани-підказки перед реєстрацією.
- **Налаштування** (`lib/features/settings`), карти й геолокація для пошуку найближчих АЗС/СТО (`google_maps_flutter`, `geolocator`).

## Технічний стек

- **Flutter**, `environment.sdk` — див. `pubspec.yaml`.
- **State management**: Cubit (`flutter_bloc`/`bloc`), DI — `get_it`.
- **Навігація**: `auto_route` (`lib/app/router/app_router.dart`; `app_router.gr.dart` — згенерований, не редагувати вручну).
- **Backend**: Firebase — Auth, Firestore, Storage, Cloud Messaging, Remote Config, Crashlytics, Analytics, Dynamic Links.
- **Локалізація**: ARB-файли в `packages/core_localization` (uk/en), доступ через `S.of(context)`.
- **Дизайн-система**: `packages/design_system` — кольори, теми, радіуси, відступи (детальний опис і правила використання — `CLAUDE.md`, розділ "No hardcoded UI values").
- Повний список пакетів — `pubspec.yaml` (не дублюється тут).

## Архітектура коду

Feature-first: `lib/features/<назва>/{data,domain,presentation}`, спільний код у `packages/core*` і `packages/design_system`. Список фіч і повна структура репозиторію — `CLAUDE.md` → "Repository structure".

## White-label / флейвори

3 флейвори: `finesplus` (реальний бренд, дефолтний), `autodosje`, `carpapers` — поточний статус кожного, як додати/змінити/прибрати флейвор — `docs/white-label-playbook.md` і CLAUDE.md → "White-label flavors".

## Дизайн

Клікабельний макет нового дашборда й пов'язаних екранів (Fines+OS): https://claude.ai/artifact/U9zexMtARry73jthp6tWMg — джерело правди для UI, поки не перенесено в код. Короткий текстовий знімок поточного стану дизайну (список екранів, групи, дата) — `docs/design.md`, PDF-експорт усіх екранів (відкривається і в Figma через File → Import) — `docs/Fines+ дашборд v2 — фінальний дизайн.pdf`. Статус впровадження, що вже зроблено в коді і що лишилось — робочий хендовер-документ команди в Google Docs, актуальна адреса — CLAUDE.md → "Робочі документи".

## Команди

Базові команди для збірки/запуску/перевірки флейворів — `CLAUDE.md` → "Common commands".

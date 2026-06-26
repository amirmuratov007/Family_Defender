# План настоящих push-уведомлений

Локальные уведомления уже есть в iOS MVP. Чтобы родитель получал тревогу на свой iPhone, когда риск появился на iPhone ребёнка, нужен backend и APNs.

## Минимальная схема

1. Родитель создаёт семью.
2. Backend создаёт pairing code.
3. Ребёнок вводит pairing code в приложении.
4. Оба iPhone регистрируют APNs device token.
5. Backend связывает:
   - parent user id;
   - child device id;
   - parent APNs token;
   - child APNs token.
6. Детский iPhone отправляет риск-событие или гео-событие на backend.
7. Backend отправляет push родителю через APNs.

## Минимальные endpoint

```text
POST /api/families
POST /api/families/{familyId}/pairing-code
POST /api/devices/register
POST /api/alerts
POST /api/location-events
GET  /api/alerts
PATCH /api/alerts/{alertId}/ack
```

## Данные тревоги

Родителю не нужно получать всю переписку. Минимальный payload:

```json
{
  "childId": "child-device-id",
  "riskScore": 88,
  "riskLevel": "critical",
  "reasons": ["Секретность", "Код или доступ", "Банк или деньги"],
  "createdAt": "2026-06-26T20:00:00Z"
}
```

Минимальный payload гео-события:

```json
{
  "childId": "child-device-id",
  "latitude": 55.7558,
  "longitude": 37.6173,
  "accuracyMeters": 35,
  "eventType": "outside_safe_place",
  "nearestSafePlaceId": "home-safe-place-id",
  "createdAt": "2026-06-26T20:00:00Z"
}
```

## Что нужно в Apple Developer

- Apple Developer Program.
- Push Notifications capability для main app.
- Location Services и Background Modes / Location для детского режима.
- APNs Auth Key.
- Bundle ID: `com.heimdallgroup.familyprotection`.
- Production provisioning profile.

## Что нельзя делать

- Не отправлять полный текст переписки без явного действия пользователя.
- Не делать скрытую слежку.
- Не хранить коды, адреса, фото или документы без отдельной причины и согласия.
- Не обещать блокировку приложений до одобрения Family Controls entitlement.

# Offline Authentication Design

Goal: user stays authenticated in the desktop app when the IdP is unreachable, within a bounded time window.

## Mechanism

1. Online login (PKCE) yields ID token, access token, refresh token.
2. Tokens stored encrypted locally (AES-GCM). Key from OS keystore (Windows Credential Manager) or PIN-derived. Never plaintext, especially the refresh token.
3. JWKS (IdP public signing keys) cached alongside.
4. When offline: ID token signature verified locally against cached JWKS; claims checked by policy.
5. On reconnect: refresh tokens, refresh JWKS, detect revoked user, then return to ONLINE.

## Offline policy

- **Max-offline window** (default 7 days, configurable): measured from last successful online validation.
- Check `iss`, `aud`, `sub`, signature.
- Check `exp` / `iat` with clock-skew tolerance.
- Detect clock rollback: store last-seen time, reject if system clock goes backwards.
- Logout wipes token store and JWKS cache.

## Known trade-off

Offline mode cannot detect revocation. A user disabled at the IdP stays valid until the max-offline window ends or the app reconnects. Document and tune the window accordingly.

## Test scenarios

- Login, kill IdP, restart app: still authenticated inside window.
- Same, after window expires: rejected (use fixed test clock).
- Corrupted token store: falls back to login, no crash.
- Wrong PIN: no decryption, no partial data leak.
- Rolled-back system clock: rejected.
- Key rotation at IdP while offline: handled on reconnect via JWKS refresh.

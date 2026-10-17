# Architecture

## Overview

JavaFX desktop app. UI built with SnapFX. Authentication is pluggable via PF4J: the host app only knows the `AuthProvider` extension point, plugins supply the implementation.

```
javafx-authentication-demo/
  desktop-app/            JavaFX + SnapFX shell, PF4J host
  auth-api/               AuthProvider extension point, AuthSession, AuthState
  plugin-oidc-online/     Discovery, Authorization Code + PKCE, refresh
  plugin-oidc-offline/    Encrypted token cache, JWKS cache, offline policy
```

## Extension point

```java
public interface AuthProvider extends ExtensionPoint {
    AuthSession login();
    AuthSession refresh(AuthSession session);
    boolean validateOffline(AuthSession session);
    void logout(AuthSession session);
}
```

`AuthState`: `ONLINE`, `OFFLINE`, `LOGGED_OUT`.

## Plugins

| Plugin | Role |
|--------|------|
| `plugin-oidc-online` | OIDC discovery, Authorization Code + PKCE via system browser, loopback redirect on `127.0.0.1`, ID token validation, refresh |
| `plugin-oidc-offline` | Decorator around the online provider. Caches tokens, verifies JWTs against cached JWKS, enforces offline policy |

Removing a plugin jar from `plugins/` changes available providers at startup.

## UI

Three screens only: login, main, settings/status. Status bar shows ONLINE/OFFLINE and remaining offline grace time.

## Tech

- JDK 21 (Maven `release` 21)
- Maven multi-module
- JavaFX, SnapFX, PF4J
- JUnit 5
- Nimbus JOSE+JWT or jose4j for JWT/JWKS

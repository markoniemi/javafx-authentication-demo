# javafx-authentication-demo – Phased Plan

JavaFX desktop app (SnapFX UI, PF4J plugins) demonstrating OIDC login that keeps working when the IdP is unreachable.

**Stack:** JDK 21 (Maven `release` 21), Maven multi-module, JavaFX, SnapFX, PF4J, JUnit 5, Nimbus JOSE+JWT (or jose4j), Keycloak/own OAuth2 server as IdP.

## Module layout

```
javafx-authentication-demo/
  pom.xml                 parent (dependencyManagement, release 21)
  auth-api/               AuthProvider extension point, token/session model
  app/                    JavaFX + SnapFX shell, PF4J host
  plugin-oidc-online/     Discovery, Authorization Code + PKCE, refresh
  plugin-oidc-offline/    Encrypted token cache, JWKS cache, offline policy
  docs/
```

## Phase 0 – Skeleton
- Parent POM, 4 modules, JDK 21, CI (GitHub Actions: `mvn verify`).
- `app` shows an empty SnapFX window.
- **Done when:** `mvn verify` green on CI, app launches.

## Phase 1 – Plugin plumbing
- `auth-api`: `AuthProvider` extension point (`login`, `refresh`, `validateOffline`, `logout`), `AuthSession`, `AuthState` (ONLINE / OFFLINE / LOGGED_OUT).
- `app` loads plugins from `plugins/` dir via PF4J; fake in-memory provider plugin for testing.
- **Done when:** dropping/removing a plugin jar changes available providers at startup; unit test covers loading.

## Phase 2 – Online OIDC (PKCE)
- IdP running (own oauth2-server or Keycloak in Docker); client registered with loopback redirect.
- `plugin-oidc-online`: discovery (`/.well-known/openid-configuration`, no hardcoded endpoints), PKCE login via system browser + `127.0.0.1` listener, ID token validation (iss, aud, exp, nonce, signature), refresh.
- UI: login screen, user/claims view, logout.
- **Done when:** real login against IdP works; tests for token validation and PKCE.

## Phase 3 – Offline authentication
- `plugin-oidc-offline` wraps the online provider (decorator).
- Encrypted token store (OS keystore or PIN-derived key, AES-GCM); never plaintext refresh token.
- JWKS cache; local signature verification.
- Offline policy: max-offline window (e.g. 7 days), `exp`/`iat`/clock-skew checks, configurable.
- **Done when:** stop the IdP, restart app, user still authenticated within window and rejected after it; unit tests with fixed clock.

## Phase 4 – Reconnect and hardening
- Connectivity detection, ONLINE/OFFLINE indicator in SnapFX status bar with grace time left.
- Re-sync on reconnect (refresh, detect revoked user, key rotation -> JWKS refresh).
- Logout wipes cache. Tamper tests (corrupted store, wrong PIN, rolled-back clock).
- **Done when:** scripted scenario test: login -> kill IdP -> offline -> restore -> re-sync.

## Phase 5 – IdP portability
- Run same app against second IdP (Keycloak if phase 2 used own server, or reverse). Config change only.
- **Done when:** both IdPs pass the same integration checks.

## Phase 6 – AWS (optional)
- Deploy IdP on AWS (Cognito, or Keycloak on ECS/Fargate) via CDK or Terraform.
- Run demo against it, kill network.
- **Done when:** app logs in against AWS IdP; IaC in `infra/`.

## Risks / notes
- Offline cannot detect revocation: document the max-offline window as the trade-off.
- Verify SnapFX API/docs before building layouts (not yet checked).
- Keep UI to three screens: login, main, settings/status.

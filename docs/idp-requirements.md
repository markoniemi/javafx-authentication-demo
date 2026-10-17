# IdP Requirements

The plugins use OIDC discovery only, no hardcoded endpoints. Switching IdP is a configuration change.

## Required from the IdP

- `/.well-known/openid-configuration` discovery
- `jwks_uri` with public signing keys (RS256 or ES256)
- Authorization Code flow with PKCE
- ID token with `iss`, `sub`, `aud`, `exp`, `iat`, `nonce`
- Refresh tokens (essential for the offline flow)
- Loopback redirect URI allowed for the client (`http://127.0.0.1:<port>`)

## Candidates

| IdP | Notes |
|-----|-------|
| Own oauth2-server | Phase 2 default if OIDC-compliant (Spring Authorization Server meets all requirements). Short token lifetimes are handy for testing offline expiry |
| Keycloak (Docker) | Fallback if own server lacks refresh tokens, PKCE or JWKS. Also the second IdP to prove portability |

A plain OAuth2 server without OIDC has no ID token and no discovery: add OIDC or use Keycloak.

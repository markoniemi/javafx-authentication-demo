---
name: java-review
description: "Review Java code in this project against its coding standards (Google Java Style, JavaFX, PF4J plugins, auth/crypto hygiene, JUnit 5). Invoke with a file path or paste code to review."
---

# Java Code Review

Review the specified file against this project's standards. If no file specified, ask user which file to review.

## How to review

1. Read target file(s).
2. Check the checklist below.
3. Report findings grouped by severity:
   - **Must fix** — security, correctness, or hard project rules
   - **Should fix** — style or maintainability issues
   - **Consider** — optional improvements
4. For each finding: file path + line number, rule violated, one-line fix.
5. Brief summary paragraph.

Do NOT rewrite whole file. Propose targeted edits only.

---

## Checklist

### Style & Formatting
- [ ] Two-space indentation; clear names; no commented code; Javadoc only for public API

### Architecture & Modules
- [ ] Plugins depend on `auth-api` only; `app` never depends on a plugin module
- [ ] Extension points defined in `auth-api`; implementations annotated `@Extension` in plugins
- [ ] Cross-plugin dependencies declared via `Plugin-Dependencies`, not classloader tricks
- [ ] Constructor injection or explicit wiring; no static singletons for state
- [ ] Immutable value types (records) for tokens, sessions and policy
- [ ] Classpath only; no `module-info.java`

### JavaFX
- [ ] UI changes only on the FX Application Thread (`Platform.runLater`)
- [ ] No blocking I/O (network, keystore, disk) on the FX thread; use `Task`/executors
- [ ] No business or auth logic in controllers/views

### Auth & Security
- [ ] ID token validated: signature, `iss`, `aud`, `exp`, `nonce`
- [ ] PKCE (`S256`) and `state` used; redirect on `127.0.0.1` loopback only
- [ ] No hardcoded endpoints; endpoints come from OIDC discovery
- [ ] Refresh token and tokens never stored in plaintext, never logged
- [ ] Encryption uses AES-GCM with a fresh random nonce per write; keys never derived without a KDF
- [ ] Time handled through an injected `Clock`; no `Instant.now()` in policy code
- [ ] Failure modes fail closed (corrupt store, bad signature, expired window -> not authenticated)

### Exceptions & Error Handling
- [ ] Specific exceptions; no swallowed exceptions; no `catch (Exception)` without rethrow or reason
- [ ] Auth failures carry a reason usable by the UI without leaking secrets

### Testing
- [ ] JUnit 5 + Mockito; fixed `Clock` for time-dependent tests
- [ ] Test names: `methodNameWithStateUnderTestExpectedBehavior`
- [ ] Tamper cases covered: corrupted store, wrong PIN, rolled-back clock
- [ ] JUnit 5 assertions only

### Single Responsibility
- [ ] One reason to change per class/method
- [ ] Methods ≤ ~20 lines; no DRY violations

### Dependencies
- [ ] Check if dependencies have newer versions or are unmaintained (`mvn dependency:tree`, Maven Central, GitHub activity)

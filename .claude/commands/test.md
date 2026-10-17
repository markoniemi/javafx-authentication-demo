Run the full Maven build and tests, then report a summary of results.

Run from the repository root:

```bash
mvn verify 2>&1 | grep -E "Tests run:|FAIL|ERROR|BUILD"
```

Before reporting, check that `*/target/surefire-reports/*.txt` were modified by this run. If they are stale, say so and do not report the modules as passing.

After running, summarize:
- How many tests passed / failed / skipped, per module
- List any failing tests with their error messages
- If all tests pass, confirm with a single line

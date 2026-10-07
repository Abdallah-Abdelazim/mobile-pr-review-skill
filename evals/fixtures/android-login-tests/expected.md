# Expected — android-login-tests

## Must find
- id: test-never-calls-vm | file: app/src/test/java/com/example/login/LoginViewModelTest.kt | line: ~17-20 | min severity: HIGH | the new test builds `LoginUiState` locally and asserts on it — it never calls `vm.onSubmit()`, so it passes regardless of the implementation.
- id: password-rule-weakened | file: app/src/main/java/com/example/login/LoginViewModel.kt | line: ~21 | min severity: HIGH | minimum password length silently lowered 8 → 6; not mentioned in the PR intent, and no test covers the boundary (the existing test uses 5 chars, so it still passes).

## Should find
- id: hardcoded-error | file: LoginViewModel.kt | user-visible error string hardcoded in the ViewModel.
- id: unused-vm | file: LoginViewModelTest.kt | `vm` is created but unused in the new test.

## Must not flag
- The existing `canSubmit is false for a short password` test (unchanged).

## Max comments: 6

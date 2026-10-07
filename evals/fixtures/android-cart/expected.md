# Expected — android-cart

## Must find
- id: first-on-empty | file: app/src/main/java/com/example/cart/CartViewModel.kt | line: ~27 | min severity: HIGH | `items.first()` throws `NoSuchElementException` when the cart is empty (repository documents empty carts) — crash in `viewModelScope`.
- id: broad-catch | file: app/src/main/java/com/example/cart/CartViewModel.kt | line: ~36-37 | min severity: MEDIUM | `catch (e: Exception)` swallows `CancellationException` and the coupon failure produces no user-facing state (invalid code silently does nothing); log drops the exception.
- id: collect-as-state | file: app/src/main/java/com/example/cart/CartScreen.kt | line: ~15 | min severity: LOW | `collectAsState()` should be `collectAsStateWithLifecycle()`.

## Should find
- id: load-resets-discount | file: CartViewModel.kt | line: ~27 | `load()` rebuilds `CartUiState` from scratch, so reloading drops an applied `discountCents`.
- id: hardcoded-strings | file: CartScreen.kt | line: ~17-20 | user-visible strings hardcoded instead of string resources.
- id: no-tests | file: CartViewModel.kt | new coupon/featured behavior has no tests.

## Must not flag
- CartScreen.kt `Modifier.padding(16.dp)` — idiomatic Compose dimension, not a "hardcoded dimension" defect.
- CartScreen.kt `onCheckout` lambda / `List<CartItem>` stability — strong skipping handles both.
- Modifier ordering in CartScreen.kt — nothing order-dependent here.

## Max comments: 10

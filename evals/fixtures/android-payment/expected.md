# Expected — android-payment

## Must find
- id: wallet-fee | file: PaymentMethod.kt (anchored on the `WALLET` line, naming `FeeCalculator.kt:6`) | min severity: HIGH | `FeeCalculator.feeCents`'s `else ->` branch (file not in the diff) charges the 3% card fee on `WALLET`, contradicting "no processing fee". Finding must name FeeCalculator.kt.
- id: tip-dropped | file: app/src/main/java/com/example/pay/Payment.kt | line: ~6-13 | min severity: HIGH | `tipCents` is added to `Payment` but `toRequest()` / `PaymentRequestDto` never send it — the stated "tip charged with the order" never happens.

## Should find
- id: else-swallows-variants | file: FeeCalculator.kt or PaymentMethod.kt | the `else` branch over an enum swallows future variants; make the `when` exhaustive.
- id: no-tests | new wallet/tip behavior has no tests.

## Must not flag
- Anything on PaymentDto.kt's new `WALLET -> "wallet"` line as a defect.

## Max comments: 6

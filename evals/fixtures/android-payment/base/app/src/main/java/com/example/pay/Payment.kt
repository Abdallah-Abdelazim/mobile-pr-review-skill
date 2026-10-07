package com.example.pay

data class Payment(
    val method: PaymentMethod,
    val amountCents: Long,
)

fun Payment.toRequest(): PaymentRequestDto =
    PaymentRequestDto(
        method = method.toApi(),
        amountCents = amountCents + FeeCalculator.feeCents(method, amountCents),
    )

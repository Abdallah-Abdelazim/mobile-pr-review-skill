package com.example.price

import java.text.NumberFormat
import java.util.Currency
import java.util.Locale

fun formatPrice(cents: Long, currencyCode: String, locale: Locale): String {
    val format = NumberFormat.getCurrencyInstance(locale)
    format.currency = Currency.getInstance(currencyCode)
    return format.format(cents / 100.0)
}

fun formatTotal(itemsCents: List<Long>, currencyCode: String, locale: Locale): String {
    val format = NumberFormat.getCurrencyInstance(locale)
    format.currency = Currency.getInstance(currencyCode)
    return format.format(itemsCents.sum() / 100.0)
}

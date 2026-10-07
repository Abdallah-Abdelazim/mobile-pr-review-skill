package com.example.price

import java.text.NumberFormat
import java.util.Currency
import java.util.Locale

fun formatPrice(cents: Long, currencyCode: String, locale: Locale): String =
    currencyFormat(currencyCode, locale).format(cents / 100.0)

fun formatTotal(itemsCents: List<Long>, currencyCode: String, locale: Locale): String =
    formatPrice(itemsCents.sum(), currencyCode, locale)

private fun currencyFormat(currencyCode: String, locale: Locale): NumberFormat =
    NumberFormat.getCurrencyInstance(locale).apply { currency = Currency.getInstance(currencyCode) }

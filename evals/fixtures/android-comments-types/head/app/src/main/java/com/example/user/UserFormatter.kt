package com.example.user

data class User(val name: String, val title: String?)

/**
 * Formats a user for display.
 *
 * @param user the user to format
 * @param includeTitle whether to prefix the user's title
 * @return the title (when requested) followed by the name
 */
fun formatUser(user: User): String = user.name

data class LoadResult(
    val user: User?,
    val error: Throwable?,
)

fun describe(result: LoadResult): String = when {
    result.user != null -> formatUser(result.user)
    else -> "Error: ${result.error?.message}"
}

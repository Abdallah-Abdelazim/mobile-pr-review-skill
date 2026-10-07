package com.example.user

data class User(val name: String, val title: String?)

/**
 * Formats a user for display.
 *
 * @param user the user to format
 * @param includeTitle whether to prefix the user's title
 * @return the title (when requested) followed by the name
 */
fun formatUser(user: User, includeTitle: Boolean): String =
    if (includeTitle && user.title != null) "${user.title} ${user.name}" else user.name

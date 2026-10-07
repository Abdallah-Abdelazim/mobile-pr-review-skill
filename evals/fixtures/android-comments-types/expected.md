# Expected — android-comments-types

## Must find
- id: stale-caller | file: app/src/main/java/com/example/user/UserFormatter.kt (anchored on the new `formatUser` signature, naming `ProfileHeader.kt:3`) | min severity: HIGH | `ProfileHeader.kt` (not in the diff) still calls `formatUser(user, includeTitle = true)` — compile break.
- id: stranded-kdoc | file: app/src/main/java/com/example/user/UserFormatter.kt | line: ~9-10 | min severity: LOW | `@param includeTitle` and the `@return` "title (when requested)" text survive the parameter's removal.
- id: load-result-invariant | file: app/src/main/java/com/example/user/UserFormatter.kt | line: ~14-17 | min severity: MEDIUM | `LoadResult` has two mutually exclusive nullable fields (both-null / both-set representable); model as a sealed type.

## Should find
- id: describe-else | file: UserFormatter.kt | line: ~21 | `else` branch prints "Error: null" when both fields are null.

## Must not flag
- `data class User` as a defect in itself (it's unchanged). A note that this diff left `User.title` unused is valid — it's dead code the change created.

## Max comments: 6

# elm-random-regex

Turn regular expressions into random strings (can be used for fuzz-testing)

``` elm
import Random.Regex exposing (..)

...
  
generate ASCII 200 "a-z*" of
    Ok result ->
        ( model, Random.generate GenResult result )

    Err msg ->
        ( { model | result = msg }, Cmd.none )
```

module Random.Regex
    exposing
        ( Encoding(..)
        , ascii
        , generate
        , unicode
        )

{-| This library helps you generate random strings from regular expressions.

It is not tested yet, but in most cases it works. What is missing so far, is

@docs ascii, generate, unicode

@docs Encoding

-}

import Char
import Combine exposing (..)
import Combine.Num exposing (..)
import Random exposing (Generator)
import Random.Extra as RandomX
import Regex


type alias State =
    { encoding : Encoding
    , infinity : Int
    }


{-| Encoding defines the type of random characters to generate, for example for
the `.` dot operator.

    - `ASCII` : will generate values between 0 and 255
    - `UNICODE` : will generate 16 bit values

-}
type Encoding
    = ASCII
    | UNICODE


{-| Create a generator that produces strings based on regular expressions.

    generate ASCII 200 "a-z*" of
        Ok result ->
            ( model, Random.generate GenResult result )

        Err msg ->
            ( { model | result = msg }, Cmd.none )

-}
generate : Encoding -> Int -> String -> Result String (Random.Generator String)
generate encoding infinity pattern =
    case runParser regexParser (State encoding infinity) pattern of
        Ok ( _, _, rand ) ->
            Ok rand

        Err ( _, _, errors ) ->
            Err (String.join " or " errors)


{-| Create a generator that produces ASCII strings based on a regular
expression. Infinty is set to max 100, if you are using modifiers such as
`*` or `+`. It is a shortcut for function `generate`.
-}
ascii : String -> Result String (Random.Generator String)
ascii =
    generate ASCII 100


{-| Create a generator that produces UNICODE strings based on a regular
expression. Infinty is set to max 100, if you are using modifiers such as
`*` or `+`. It is a shortcut for function `generate`.
-}
unicode : String -> Result String (Random.Generator String)
unicode =
    generate UNICODE 100


regexParser : Parser State (Generator String)
regexParser =
    RandomX.combine
        >> Random.map List.concat
        >> Random.map (List.map Char.fromCode)
        >> Random.map String.fromList
        <$> many options


options : Parser State (Generator (List Int))
options =
    let
        helper () =
            (\rand quantifier greedy ->
                case ( quantifier, greedy ) of
                    ( Just fn, Nothing ) ->
                        fn rand

                    ( Just fn, Just re ) ->
                        non_greedy re <| fn rand

                    _ ->
                        rand
            )
                <$> choice
                        [ choice_
                        , group_
                        , singletons
                        ]
                <*> maybe quantifiers
                <*> maybe (string "?" *> regex_regex)
    in
    lazy helper


(...) : Int -> Int -> Generator Int
(...) from to =
    Random.int from to


quantifiers : Parser State (Generator (List Int) -> Generator (List Int))
quantifiers =
    choice
        [ repeat 0 <$> (string "*" *> infinity)
        , repeat 1 <$> (string "+" *> infinity)
        , repeat 0 1 <$ string "?"
        , (\i -> repeat i i) <$> braces (maybe (string ",") *> int)
        , repeat <$> braces (int <* string ",") <*> infinity
        , braces (repeat <$> int <*> (string "," *> int))
        ]


singletons : Parser State (Generator (List Int))
singletons =
    Random.map List.singleton
        <$> choice
                [ dot_
                , range_
                , escape
                , constat_
                ]


encoding : Parser State Encoding
encoding =
    withState (.encoding >> succeed)


infinity : Parser State Int
infinity =
    withState (.infinity >> succeed)


dot_ : Parser State (Generator Int)
dot_ =
    (\encoding ->
        case encoding of
            ASCII ->
                32 ... (2 ^ 8)

            UNICODE ->
                32 ... (2 ^ 16)
    )
        <$> (string "." *> encoding)


range_ : Parser State (Generator Int)
range_ =
    (\from to -> string2code from ... string2code to)
        <$> regex "[^\\(\\[]"
        <*> (string "-" *> regex "[^\\)\\]]")


constat_ : Parser State (Generator Int)
constat_ =
    (string2code >> RandomX.constant) <$> regex "[^\\[\\]\\(\\)\\|\\?]"


choice_ : Parser State (Generator (List Int))
choice_ =
    RandomX.choices <$> brackets (many singletons)


group_ : Parser State (Generator (List Int))
group_ =
    RandomX.choices
        <$> parens
                (sepBy (string "|")
                    (RandomX.combine >> Random.map List.concat <$> many options)
                )


regex_regex : Parser State Regex.Regex
regex_regex =
    Regex.regex <$> regex "(\\[\\^?[^\\]]+\\]|\\([^\\)]+\\)|\\w)([+*]|\\{[^\\}]\\})?"


non_greedy : Regex.Regex -> Generator (List Int) -> Generator (List Int)
non_greedy re p =
    p
        |> RandomX.filter
            (List.map Char.fromCode
                >> String.fromList
                >> Regex.contains re
                >> not
            )


repeat : Int -> Int -> Generator (List Int) -> Generator (List Int)
repeat from to p =
    p
        |> RandomX.rangeLengthList from to
        |> Random.map List.concat


escape : Parser State (Generator Int)
escape =
    string "\\"
        *> choice
            [ string "d" $> 48 ... 57
            , filter (\i -> (i < 48) || (i > 57)) <$> (string "D" *> encoding)
            , string "w"
                $> (words
                        |> RandomX.sample
                        |> Random.map (Maybe.withDefault 65)
                   )
            , filter (\i -> not <| List.member i words) <$> (string "W" *> encoding)
            , (\enc ->
                enc
                    |> spaces
                    |> RandomX.sample
                    |> Random.map (Maybe.withDefault 32)
              )
                <$> (string "s" *> encoding)
            , (\enc ->
                filter (\i -> not <| List.member i <| spaces enc) enc
              )
                <$> (string "S" *> encoding)
            , string "n" $> RandomX.constant 10
            , string "t" $> RandomX.constant 9
            , string "r" $> RandomX.constant 13
            , string "f" $> RandomX.constant 12
            , string "v" $> RandomX.constant 11
            , string "b" $> RandomX.constant 8
            , string "0" $> RandomX.constant 0
            , hex_string <$> (string "x" *> regex "[0-9A-Fa-f]{2}")
            , hex_string <$> (string "u" *> regex "[0-9A-Fa-f]{4}")
            , string2code >> RandomX.constant <$> regex "."
            ]


spaces : Encoding -> List Int
spaces encoding =
    case encoding of
        ASCII ->
            [ 9, 10, 11, 12, 13, 32, 160 ]

        UNICODE ->
            [ 9, 10, 11, 12, 13, 32, 160, 5760, 6158, 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8201, 8202, 8232, 8233 ]


words : List Int
words =
    [ List.range 65 90 -- A-Z
    , List.range 97 122 -- a-z
    , [ 95 ] -- _
    ]
        |> List.concat


filter : (Int -> Bool) -> Encoding -> Generator Int
filter fn encoding =
    case encoding of
        ASCII ->
            RandomX.filter fn (0 ... (2 ^ 8))

        UNICODE ->
            RandomX.filter fn (0 ... (2 ^ 16))


string2code : String -> Char.KeyCode
string2code =
    String.toList >> List.head >> Maybe.withDefault ' ' >> Char.toCode


hex_string : String -> Generator Int
hex_string hex =
    "0x"
        ++ hex
        |> String.toInt
        |> Result.withDefault 32
        |> RandomX.constant

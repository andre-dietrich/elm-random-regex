module Random.Regex
    exposing
        ( Encoding(..)
        , ascii
        , generator
        , unicode
        )

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


type Encoding
    = ASCII
    | UNICODE


generator : Encoding -> Int -> String -> Result String (Random.Generator String)
generator encoding infinity pattern =
    case runParser regexParser (State encoding infinity) pattern of
        Ok ( _, _, rand ) ->
            Ok rand

        Err ( _, _, errors ) ->
            Err (String.join " or " errors)


ascii : String -> Result String (Random.Generator String)
ascii =
    generator ASCII 100


unicode : String -> Result String (Random.Generator String)
unicode =
    generator UNICODE 100


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
        modifiers =
            choice
                [ non_greedy 0 <$> (string "*?" *> infinity) <*> regex_regex
                , repeat 0 <$> (string "*" *> infinity)
                , non_greedy 1 <$> (string "+?" *> infinity) <*> regex_regex
                , repeat 1 <$> (string "+" *> infinity)
                , string "?" $> repeat 0 1
                , (\i -> repeat i i) <$> braces (maybe (string ",") *> int)
                , repeat <$> braces (int <* string ",") <*> infinity
                , braces (repeat <$> int <*> (string "," *> int))
                ]

        helper () =
            (\a b ->
                case b of
                    Just fn ->
                        fn a

                    _ ->
                        a
            )
                <$> choice
                        [ choice_
                        , group_
                        , singletons
                        ]
                <*> maybe modifiers
    in
    lazy helper


(...) : Int -> Int -> Generator Int
(...) from to =
    Random.int from to


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
    (string2code >> RandomX.constant) <$> regex "[^\\[\\]\\(\\)\\|]"


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


non_greedy : Int -> Int -> Regex.Regex -> Generator (List Int) -> Generator (List Int)
non_greedy from to re p =
    p
        |> repeat from to
        |> RandomX.filter (List.map Char.fromCode >> String.fromList >> Debug.log "Fuck" >> Regex.contains re >> not)


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

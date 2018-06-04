module RegexGenerator exposing (regexGen)

import Char
import Combine exposing (..)
import Combine.Num exposing (..)
import Random
import Random.Extra as RandEx
import Regex


type alias GenInt =
    Random.Generator Int


type alias GenLst =
    Random.Generator (List Int)



--regex : String -> Random.Generator String


regexGen pattern =
    parse regexParser pattern


regexParser : Parser s (Random.Generator String)
regexParser =
    gen2str <$> many options


options : Parser s GenLst
options =
    let
        helper () =
            choice
                [ choice_ >>= star_ >>= non_greedy
                , choice_ >>= star_
                , choice_ >>= plus_ >>= non_greedy
                , choice_ >>= plus_
                , choice_ >>= question_mark
                , choice_ >>= max_
                , choice_ >>= min_
                , choice_ >>= min_max
                , choice_
                , group_ >>= star_ >>= non_greedy
                , group_ >>= star_
                , group_ >>= plus_ >>= non_greedy
                , group_ >>= plus_
                , group_ >>= question_mark
                , group_ >>= max_
                , group_ >>= min_
                , group_ >>= min_max
                , group_
                , singletons >>= star_ >>= non_greedy
                , singletons >>= star_
                , singletons >>= plus_ >>= non_greedy
                , singletons >>= plus_
                , singletons >>= question_mark
                , singletons >>= max_
                , singletons >>= min_
                , singletons >>= min_max
                , singletons
                ]
    in
    lazy helper


(...) : Int -> Int -> GenInt
(...) from to =
    Random.int from to


gen2str : List GenLst -> Random.Generator String
gen2str =
    RandEx.combine
        >> Random.map List.concat
        >> Random.map (List.map Char.fromCode)
        >> Random.map String.fromList


singletons : Parser s GenLst
singletons =
    Random.map List.singleton
        <$> choice
                [ dot_
                , range_
                , escape
                , constat_
                ]


dot_ : Parser s GenInt
dot_ =
    string "." $> 36 ... (2 ^ 16)


range_ : Parser s GenInt
range_ =
    (\from to -> string2code from ... string2code to)
        <$> regex "."
        <*> (string "-" *> regex ".")


constat_ : Parser s GenInt
constat_ =
    (string2code >> RandEx.constant) <$> regex "[^\\[\\]\\(\\)\\|]"


choice_ : Parser s GenLst
choice_ =
    RandEx.choices <$> brackets (many1 singletons)


group_ : Parser s GenLst
group_ =
    RandEx.choices
        <$> parens
                (sepBy (string "|")
                    (RandEx.combine
                        >> Random.map List.concat
                        <$> many options
                    )
                )


star_ : GenLst -> Parser s GenLst
star_ p =
    string "*" $> repeat 0 100 p


non_greedy : GenLst -> Parser s GenLst
non_greedy p =
    string_contains p <$> (string "?" *> regex "(\\[\\^?[^\\]]+\\]|\\([^\\)]+\\)|\\w)([+*]|\\{[^\\}]\\})?")


string_contains : GenLst -> String -> GenLst
string_contains p re =
    RandEx.filter (List.map Char.fromCode >> String.fromList >> Debug.log "Fuck" >> Regex.contains (Regex.regex re) >> not) p


plus_ : GenLst -> Parser s GenLst
plus_ p =
    string "+" $> repeat 1 100 p


nothing : GenLst -> Parser s GenLst
nothing p =
    succeed p


question_mark : GenLst -> Parser s GenLst
question_mark p =
    string "?" $> repeat 0 1 p


max_ : GenLst -> Parser s GenLst
max_ p =
    (\i -> repeat i i p) <$> braces (maybe (string ",") *> int)


min_ : GenLst -> Parser s GenLst
min_ p =
    (\i -> repeat i 100 p) <$> braces (int <* string ",")


min_max : GenLst -> Parser s GenLst
min_max p =
    braces ((\i j -> repeat i j p) <$> int <*> (string "," *> int))


repeat : Int -> Int -> GenLst -> GenLst
repeat from to p =
    p
        |> RandEx.rangeLengthList from to
        |> Random.map List.concat


escape : Parser s GenInt
escape =
    string "\\"
        *> choice
            [ string "d" $> 48 ... 57
            , string "D" $> filter (\i -> (i < 48) || (i > 57))
            , string "w"
                $> (words
                        |> RandEx.sample
                        |> Random.map (Maybe.withDefault 65)
                   )
            , string "W" $> filter (\i -> not <| List.member i words)
            , string "s"
                $> (spaces
                        |> RandEx.sample
                        |> Random.map (Maybe.withDefault 32)
                   )
            , string "S" $> filter (\i -> not <| List.member i spaces)
            , string "n" $> RandEx.constant 10
            , string "t" $> RandEx.constant 9
            , string "r" $> RandEx.constant 13
            , string "f" $> RandEx.constant 12
            , string "v" $> RandEx.constant 11
            , string "b" $> RandEx.constant 8
            , string "0" $> RandEx.constant 0
            , hex_string <$> (string "x" *> regex "[0-9A-Fa-f]{2}")
            , hex_string <$> (string "u" *> regex "[0-9A-Fa-f]{4}")
            , string2code >> RandEx.constant <$> regex "."
            ]


spaces : List Int
spaces =
    [ 9, 10, 11, 12, 13, 32, 160, 5760, 6158, 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8201, 8202, 8232, 8233 ]


words : List Int
words =
    [ List.range 65 90 -- A-Z
    , List.range 97 122 -- a-z
    , [ 95 ] -- _
    ]
        |> List.concat


filter : (Int -> Bool) -> GenInt
filter fn =
    RandEx.filter fn (0 ... (2 ^ 16))


string2code : String -> Char.KeyCode
string2code =
    String.toList >> List.head >> Maybe.withDefault ' ' >> Char.toCode


hex_string : String -> GenInt
hex_string hex =
    "0x"
        ++ hex
        |> String.toInt
        |> Result.withDefault 32
        |> RandEx.constant

module Random.Regex exposing
    ( ascii, generate, unicode
    , Encoding(..)
    )

{-| This library helps you generate random strings from regular expressions.

It is not tested yet, but in most cases it works. What is missing so far are
assertions and back references.

Tested regular expressions:

  - _Date_ :
    "(January|February|March|April|May|June|July|August|September|October|November|December) ([1-9]|[12][0-9]|3[01]), (19|20)[0-9]"

    `August 12, 1943`

  - _Time_ :
    "(1[0-2]|0[1-9])(:[0-5]\\d){2} (A|P)M"

    `06:01:34 AM`

  - _SHA1 Hash_ :
    "[a-f0-9]{40}"

    `1744620aca430ed0a084aa294b2651e7c78be09e`

  - _Currency_ :
    "$([1-9]{1,3}(,\\d{3}){0,3}|([1-9]{1,3}))(.\\d{2})?"

    `$357,595,758,499.02`

  - _Lorem ipsum ..._:
    "((Exercitationem|Perferendis|Perspiciatis|Laborum|Eveniet|Sunt|Iure|Nam|Nobis|Eum|Cum|Officiis|Excepturi|Odio|Consectetur|Quasi|Aut|Quisquam|Vel|Eligendi|Itaque|Non|Odit|Tempore|Quaerat|Dignissimos|Facilis|Neque|Nihil|Expedita|Vitae|Vero|Ipsum|Nisi|Animi|Cumque|Pariatur|Velit|Modi|Natus|Iusto|Eaque|Sequi|Illo|Sed|Ex|Et|Voluptatibus|Tempora|Veritatis|Ratione|Assumenda|Incidunt|Nostrum|Placeat|Aliquid|Fuga|Provident|Praesentium|Rem|Necessitatibus|Suscipit|Adipisci|Quidem|Possimus|Voluptas|Debitis|Sint|Accusantium|Unde|Sapiente|Voluptate|Qui|Aspernatur|Laudantium|Soluta|Amet|Quo|Aliquam|Saepe|Culpa|Libero|Ipsa|Dicta|Reiciendis|Nesciunt|Doloribus|Autem|Impedit|Minima|Maiores|Repudiandae|Ipsam|Obcaecati|Ullam|Enim|Totam|Delectus|Ducimus|Quis|Voluptates|Dolores|Molestiae|Harum|Dolorem|Quia|Voluptatem|Molestias|Magni|Distinctio|Omnis|Illum|Dolorum|Voluptatum|Ea|Quas|Quam|Corporis|Quae|Blanditiis|Atque|Deserunt|Laboriosam|Earum|Consequuntur|Hic|Cupiditate|Quibusdam|Accusamus|Ut|Rerum|Error|Minus|Eius|Ab|Ad|Nemo|Fugit|Officia|At|In|Id|Quos|Reprehenderit|Numquam|Iste|Fugiat|Sit|Inventore|Beatae|Repellendus|Magnam|Recusandae|Quod|Explicabo|Doloremque|Aperiam|Consequatur|Asperiores|Commodi|Optio|Dolor|Labore|Temporibus|Repellat|Veniam|Architecto|Est|Esse|Mollitia|Nulla|A|Similique|Eos|Alias|Dolore|Tenetur|Deleniti|Porro|Facere|Maxime|Corrupti)( (exercitationem|perferendis|perspiciatis|laborum|eveniet|sunt|iure|nam|nobis|eum|cum|officiis|excepturi|odio|consectetur|quasi|aut|quisquam|vel|eligendi|itaque|non|odit|tempore|quaerat|dignissimos|facilis|neque|nihil|expedita|vitae|vero|ipsum|nisi|animi|cumque|pariatur|velit|modi|natus|iusto|eaque|sequi|illo|sed|ex|et|voluptatibus|tempora|veritatis|ratione|assumenda|incidunt|nostrum|placeat|aliquid|fuga|provident|praesentium|rem|necessitatibus|suscipit|adipisci|quidem|possimus|voluptas|debitis|sint|accusantium|unde|sapiente|voluptate|qui|aspernatur|laudantium|soluta|amet|quo|aliquam|saepe|culpa|libero|ipsa|dicta|reiciendis|nesciunt|doloribus|autem|impedit|minima|maiores|repudiandae|ipsam|obcaecati|ullam|enim|totam|delectus|ducimus|quis|voluptates|dolores|molestiae|harum|dolorem|quia|voluptatem|molestias|magni|distinctio|omnis|illum|dolorum|voluptatum|ea|quas|quam|corporis|quae|blanditiis|atque|deserunt|laboriosam|earum|consequuntur|hic|cupiditate|quibusdam|accusamus|ut|rerum|error|minus|eius|ab|ad|nemo|fugit|officia|at|in|id|quos|reprehenderit|numquam|iste|fugiat|sit|inventore|beatae|repellendus|magnam|recusandae|quod|explicabo|doloremque|aperiam|consequatur|asperiores|commodi|optio|dolor|labore|temporibus|repellat|veniam|architecto|est|esse|mollitia|nulla|a|similique|eos|alias|dolore|tenetur|deleniti|porro|facere|maxime|corrupti)){2,12}(, (exercitationem|perferendis|perspiciatis|laborum|eveniet|sunt|iure|nam|nobis|eum|cum|officiis|excepturi|odio|consectetur|quasi|aut|quisquam|vel|eligendi|itaque|non|odit|tempore|quaerat|dignissimos|facilis|neque|nihil|expedita|vitae|vero|ipsum|nisi|animi|cumque|pariatur|velit|modi|natus|iusto|eaque|sequi|illo|sed|ex|et|voluptatibus|tempora|veritatis|ratione|assumenda|incidunt|nostrum|placeat|aliquid|fuga|provident|praesentium|rem|necessitatibus|suscipit|adipisci|quidem|possimus|voluptas|debitis|sint|accusantium|unde|sapiente|voluptate|qui|aspernatur|laudantium|soluta|amet|quo|aliquam|saepe|culpa|libero|ipsa|dicta|reiciendis|nesciunt|doloribus|autem|impedit|minima|maiores|repudiandae|ipsam|obcaecati|ullam|enim|totam|delectus|ducimus|quis|voluptates|dolores|molestiae|harum|dolorem|quia|voluptatem|molestias|magni|distinctio|omnis|illum|dolorum|voluptatum|ea|quas|quam|corporis|quae|blanditiis|atque|deserunt|laboriosam|earum|consequuntur|hic|cupiditate|quibusdam|accusamus|ut|rerum|error|minus|eius|ab|ad|nemo|fugit|officia|at|in|id|quos|reprehenderit|numquam|iste|fugiat|sit|inventore|beatae|repellendus|magnam|recusandae|quod|explicabo|doloremque|aperiam|consequatur|asperiores|commodi|optio|dolor|labore|temporibus|repellat|veniam|architecto|est|esse|mollitia|nulla|a|similique|eos|alias|dolore|tenetur|deleniti|porro|facere|maxime|corrupti)( (exercitationem|perferendis|perspiciatis|laborum|eveniet|sunt|iure|nam|nobis|eum|cum|officiis|excepturi|odio|consectetur|quasi|aut|quisquam|vel|eligendi|itaque|non|odit|tempore|quaerat|dignissimos|facilis|neque|nihil|expedita|vitae|vero|ipsum|nisi|animi|cumque|pariatur|velit|modi|natus|iusto|eaque|sequi|illo|sed|ex|et|voluptatibus|tempora|veritatis|ratione|assumenda|incidunt|nostrum|placeat|aliquid|fuga|provident|praesentium|rem|necessitatibus|suscipit|adipisci|quidem|possimus|voluptas|debitis|sint|accusantium|unde|sapiente|voluptate|qui|aspernatur|laudantium|soluta|amet|quo|aliquam|saepe|culpa|libero|ipsa|dicta|reiciendis|nesciunt|doloribus|autem|impedit|minima|maiores|repudiandae|ipsam|obcaecati|ullam|enim|totam|delectus|ducimus|quis|voluptates|dolores|molestiae|harum|dolorem|quia|voluptatem|molestias|magni|distinctio|omnis|illum|dolorum|voluptatum|ea|quas|quam|corporis|quae|blanditiis|atque|deserunt|laboriosam|earum|consequuntur|hic|cupiditate|quibusdam|accusamus|ut|rerum|error|minus|eius|ab|ad|nemo|fugit|officia|at|in|id|quos|reprehenderit|numquam|iste|fugiat|sit|inventore|beatae|repellendus|magnam|recusandae|quod|explicabo|doloremque|aperiam|consequatur|asperiores|commodi|optio|dolor|labore|temporibus|repellat|veniam|architecto|est|esse|mollitia|nulla|a|similique|eos|alias|dolore|tenetur|deleniti|porro|facere|maxime|corrupti)){2,12}){0,5}[.?] ){1,4}"

    `Debitis perspiciatis enim, obcaecati natus beatae nobis praesentium corporis asperiores sint vitae voluptas, sunt harum sit enim mollitia laboriosam quod explicabo minima nulla eaque deleniti hic? Deserunt quas nulla, corporis nobis blanditiis explicabo amet error necessitatibus earum, cum qui repudiandae sunt similique deserunt sed reprehenderit sequi eaque commodi corporis, officia repellendus quod, magnam ducimus ad delectus ratione, nemo odio expedita soluta qui vel incidunt possimus neque eos pariatur? Cumque ipsam eos ratione ipsam, perferendis enim cum corrupti, quia ducimus aperiam iste laborum veritatis cupiditate exercitationem iusto veritatis natus architecto reiciendis, necessitatibus odio magnam eius vel corporis velit atque? Optio quas maxime officia deserunt soluta laboriosam quidem.`

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
generate enc inf pattern =
    case runParser regexParser (State enc inf) pattern of
        Ok ( _, _, rand ) ->
            Ok rand

        Err ( _, _, errors ) ->
            Err (String.join " or " errors)


{-| Create a generator that produces ASCII strings based on a regular
expression. Infinty is set to max 250, if you are using modifiers such as
`*` or `+`. It is a shortcut for function `generate`.
-}
ascii : String -> Result String (Generator String)
ascii =
    generate ASCII 250


{-| Create a generator that produces UNICODE strings based on a regular
expression. Infinty is set to max 250, if you are using modifiers such as
`*` or `+`. It is a shortcut for function `generate`.
-}
unicode : String -> Result String (Generator String)
unicode =
    generate UNICODE 250


regexParser : Parser State (Generator String)
regexParser =
    many options
        |> map
            (RandomX.combine
                >> Random.map List.concat
                >> Random.map (List.map Char.fromCode)
                >> Random.map String.fromList
            )


options : Parser State (Generator (List Int))
options =
    let
        helper () =
            choice
                [ choice_
                , group_
                , singletons
                ]
                |> map
                    (\rand quantifier greedy ->
                        case ( quantifier, greedy ) of
                            ( Just fn, Nothing ) ->
                                fn rand

                            ( Just fn, Just re ) ->
                                non_greedy re <| fn rand

                            _ ->
                                rand
                    )
                |> andMap (maybe quantifiers)
                |> andMap (maybe (string "?" |> keep regex_regex))
    in
    lazy helper


range : Int -> Int -> Generator Int
range from to =
    Random.int from to


quantifiers : Parser State (Generator (List Int) -> Generator (List Int))
quantifiers =
    choice
        [ string "*" |> keep infinity |> map (repeat 0)
        , map (repeat 1) (string "+" |> keep infinity)
        , string "?" |> onsuccess (repeat 0 1)
        , braces (maybe (string ",") |> keep int) |> map (\i -> repeat i i)
        , braces (int |> ignore (string ",")) |> map repeat |> andMap infinity
        , braces ((string "," |> keep int) |> map repeat |> andMap int)
        ]


singletons : Parser State (Generator (List Int))
singletons =
    [ dot_, range_, escape, constat_ ]
        |> choice
        |> map (Random.map List.singleton)


encoding : Parser State Encoding
encoding =
    withState (.encoding >> succeed)


infinity : Parser State Int
infinity =
    withState (.infinity >> succeed)


dot_ : Parser State (Generator Int)
dot_ =
    string "."
        |> keep encoding
        |> map random_dot


random_dot : Encoding -> Generator Int
random_dot enc =
    case enc of
        ASCII ->
            range 32 (2 ^ 8)

        UNICODE ->
            range 32 (2 ^ 16)


random_dotX : Encoding -> Generator Int
random_dotX enc =
    case enc of
        ASCII ->
            range 10 (2 ^ 8)

        UNICODE ->
            range 10 (2 ^ 16)


range_ : Parser State (Generator Int)
range_ =
    regex "[^\\(\\[]"
        |> map (\from to -> range (string2code from) (string2code to))
        |> andMap (string "-" |> keep (regex "[^\\)\\]]"))


constat_ : Parser State (Generator Int)
constat_ =
    regex "[^\\[\\]\\(\\)\\|\\?]"
        |> map (string2code >> Random.constant)


choice_ : Parser State (Generator (List Int))
choice_ =
    regex "\\[[^\\]]*\\]"
        |> map
            (\re enc ->
                enc
                    |> random_dotX
                    |> Random.map List.singleton
                    |> RandomX.filter (Regex.fromString re |> Maybe.withDefault Regex.never |> regex_filter)
            )
        |> andMap encoding


group_ : Parser State (Generator (List Int))
group_ =
    parens
        (sepBy (string "|")
            (map (RandomX.combine >> Random.map List.concat) (many options))
        )
        |> map (RandomX.combine >> Random.map List.concat)


regex_regex : Parser State Regex.Regex
regex_regex =
    regex "(\\[\\^?[^\\]]+\\]|\\([^\\)]+\\)|\\w)([+*]|\\{[^\\}]\\})?"
        |> map (Regex.fromString >> Maybe.withDefault Regex.never)


non_greedy : Regex.Regex -> Generator (List Int) -> Generator (List Int)
non_greedy re p =
    p
        |> RandomX.filter
            (regex_filter re >> not)


regex_filter : Regex.Regex -> List Int -> Bool
regex_filter re =
    List.map Char.fromCode
        >> String.fromList
        >> Regex.contains re


repeat : Int -> Int -> Generator (List Int) -> Generator (List Int)
repeat from to p =
    p
        |> RandomX.rangeLengthList from to
        |> Random.map List.concat


escape : Parser State (Generator Int)
escape =
    string "\\"
        |> keep
            (choice
                [ string "d" |> onsuccess (range 48 57)
                , map (filter (\i -> (i < 48) || (i > 57))) (string "D" |> keep encoding)
                , string "w"
                    |> onsuccess
                        (words
                            |> RandomX.sample
                            |> Random.map (Maybe.withDefault 65)
                        )
                , map (filter (\i -> not <| List.member i words)) (string "W" |> keep encoding)
                , map
                    (\enc ->
                        enc
                            |> spaces
                            |> RandomX.sample
                            |> Random.map (Maybe.withDefault 32)
                    )
                    (string "s" |> keep encoding)
                , map
                    (\enc ->
                        filter (\i -> not <| List.member i <| spaces enc) enc
                    )
                    (string "S" |> keep encoding)
                , string "n" |> onsuccess (Random.constant 10)
                , string "t" |> onsuccess (Random.constant 9)
                , string "r" |> onsuccess (Random.constant 13)
                , string "f" |> onsuccess (Random.constant 12)
                , string "v" |> onsuccess (Random.constant 11)
                , string "b" |> onsuccess (Random.constant 8)
                , string "0" |> onsuccess (Random.constant 0)
                , map hex_string (string "x" |> keep (regex "[0-9A-Fa-f]{2}"))
                , map hex_string (string "u" |> keep (regex "[0-9A-Fa-f]{4}"))
                , map (string2code >> Random.constant) (regex ".")
                ]
            )


spaces : Encoding -> List Int
spaces enc =
    case enc of
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
filter fn enc =
    case enc of
        ASCII ->
            RandomX.filter fn (range 0 (2 ^ 8))

        UNICODE ->
            RandomX.filter fn (range 0 (2 ^ 16))


string2code : String -> Int
string2code =
    String.toList >> List.head >> Maybe.withDefault ' ' >> Char.toCode


hex_string : String -> Generator Int
hex_string hex =
    "0x"
        ++ hex
        |> String.toInt
        |> Maybe.withDefault 32
        |> Random.constant

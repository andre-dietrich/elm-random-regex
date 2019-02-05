module Example exposing (currency, date, hash, lorem, numbers, time)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Random.Regex exposing (Encoding(..))
import Regex
import Shrink
import Test exposing (..)


fuzzRegex : String -> Fuzzer String
fuzzRegex str =
    case Random.Regex.generate ASCII 199 str of
        Ok re ->
            Fuzz.custom re Shrink.noShrink

        Err info ->
            Fuzz.invalid ("not a valid regular expression (" ++ str ++ ") => " ++ info)


numbers : Test
numbers =
    describe "generate different kinds of numbers"
        [ test "[0-9]+" Nothing
        , test "[0-9]*" Nothing
        , test "\\d+" Nothing
        , test "\\d*" Nothing
        , test "(0|1|2|3|4|5|6|7|8|9)*" Nothing
        , test "(0|1|2|3|4|5|6|7|8|9)+" Nothing
        ]


date : Test
date =
    let
        re =
            "(January|February|March|April|May|June|July|August|September|October|November|December) ([1-9]|[12][0-9]|3[01]), (19|20)[0-9]"
    in
    describe "generate different calender dates"
        [ test re Nothing ]


time : Test
time =
    let
        re =
            "(1[0-2]|0[1-9])(:[0-5]\\d){2} (A|P)M"
    in
    describe "generate different american stile timestamps"
        [ test re Nothing ]


hash : Test
hash =
    describe "generate random SHA1 hashes"
        [ test "[a-f0-9]{40}" Nothing ]


currency : Test
currency =
    describe "generate random dollar values"
        [ test "\\$([1-9]{1,3}(,\\d{3}){0,3}|([1-9]{1,3}))(\\.\\d{2})?" Nothing ]


lorem : Test
lorem =
    let
        re =
            "((Exercitationem|Perferendis|Perspiciatis|Laborum|Eveniet|Sunt|Iure|Nam|Nobis|Eum|Cum|Officiis|Excepturi|Odio|Consectetur|Quasi|Aut|Quisquam|Vel|Eligendi|Itaque|Non|Odit|Tempore|Quaerat|Dignissimos|Facilis|Neque|Nihil|Expedita|Vitae|Vero|Ipsum|Nisi|Animi|Cumque|Pariatur|Velit|Modi|Natus|Iusto|Eaque|Sequi|Illo|Sed|Ex|Et|Voluptatibus|Tempora|Veritatis|Ratione|Assumenda|Incidunt|Nostrum|Placeat|Aliquid|Fuga|Provident|Praesentium|Rem|Necessitatibus|Suscipit|Adipisci|Quidem|Possimus|Voluptas|Debitis|Sint|Accusantium|Unde|Sapiente|Voluptate|Qui|Aspernatur|Laudantium|Soluta|Amet|Quo|Aliquam|Saepe|Culpa|Libero|Ipsa|Dicta|Reiciendis|Nesciunt|Doloribus|Autem|Impedit|Minima|Maiores|Repudiandae|Ipsam|Obcaecati|Ullam|Enim|Totam|Delectus|Ducimus|Quis|Voluptates|Dolores|Molestiae|Harum|Dolorem|Quia|Voluptatem|Molestias|Magni|Distinctio|Omnis|Illum|Dolorum|Voluptatum|Ea|Quas|Quam|Corporis|Quae|Blanditiis|Atque|Deserunt|Laboriosam|Earum|Consequuntur|Hic|Cupiditate|Quibusdam|Accusamus|Ut|Rerum|Error|Minus|Eius|Ab|Ad|Nemo|Fugit|Officia|At|In|Id|Quos|Reprehenderit|Numquam|Iste|Fugiat|Sit|Inventore|Beatae|Repellendus|Magnam|Recusandae|Quod|Explicabo|Doloremque|Aperiam|Consequatur|Asperiores|Commodi|Optio|Dolor|Labore|Temporibus|Repellat|Veniam|Architecto|Est|Esse|Mollitia|Nulla|A|Similique|Eos|Alias|Dolore|Tenetur|Deleniti|Porro|Facere|Maxime|Corrupti)( (exercitationem|perferendis|perspiciatis|laborum|eveniet|sunt|iure|nam|nobis|eum|cum|officiis|excepturi|odio|consectetur|quasi|aut|quisquam|vel|eligendi|itaque|non|odit|tempore|quaerat|dignissimos|facilis|neque|nihil|expedita|vitae|vero|ipsum|nisi|animi|cumque|pariatur|velit|modi|natus|iusto|eaque|sequi|illo|sed|ex|et|voluptatibus|tempora|veritatis|ratione|assumenda|incidunt|nostrum|placeat|aliquid|fuga|provident|praesentium|rem|necessitatibus|suscipit|adipisci|quidem|possimus|voluptas|debitis|sint|accusantium|unde|sapiente|voluptate|qui|aspernatur|laudantium|soluta|amet|quo|aliquam|saepe|culpa|libero|ipsa|dicta|reiciendis|nesciunt|doloribus|autem|impedit|minima|maiores|repudiandae|ipsam|obcaecati|ullam|enim|totam|delectus|ducimus|quis|voluptates|dolores|molestiae|harum|dolorem|quia|voluptatem|molestias|magni|distinctio|omnis|illum|dolorum|voluptatum|ea|quas|quam|corporis|quae|blanditiis|atque|deserunt|laboriosam|earum|consequuntur|hic|cupiditate|quibusdam|accusamus|ut|rerum|error|minus|eius|ab|ad|nemo|fugit|officia|at|in|id|quos|reprehenderit|numquam|iste|fugiat|sit|inventore|beatae|repellendus|magnam|recusandae|quod|explicabo|doloremque|aperiam|consequatur|asperiores|commodi|optio|dolor|labore|temporibus|repellat|veniam|architecto|est|esse|mollitia|nulla|a|similique|eos|alias|dolore|tenetur|deleniti|porro|facere|maxime|corrupti)){2,12}(, (exercitationem|perferendis|perspiciatis|laborum|eveniet|sunt|iure|nam|nobis|eum|cum|officiis|excepturi|odio|consectetur|quasi|aut|quisquam|vel|eligendi|itaque|non|odit|tempore|quaerat|dignissimos|facilis|neque|nihil|expedita|vitae|vero|ipsum|nisi|animi|cumque|pariatur|velit|modi|natus|iusto|eaque|sequi|illo|sed|ex|et|voluptatibus|tempora|veritatis|ratione|assumenda|incidunt|nostrum|placeat|aliquid|fuga|provident|praesentium|rem|necessitatibus|suscipit|adipisci|quidem|possimus|voluptas|debitis|sint|accusantium|unde|sapiente|voluptate|qui|aspernatur|laudantium|soluta|amet|quo|aliquam|saepe|culpa|libero|ipsa|dicta|reiciendis|nesciunt|doloribus|autem|impedit|minima|maiores|repudiandae|ipsam|obcaecati|ullam|enim|totam|delectus|ducimus|quis|voluptates|dolores|molestiae|harum|dolorem|quia|voluptatem|molestias|magni|distinctio|omnis|illum|dolorum|voluptatum|ea|quas|quam|corporis|quae|blanditiis|atque|deserunt|laboriosam|earum|consequuntur|hic|cupiditate|quibusdam|accusamus|ut|rerum|error|minus|eius|ab|ad|nemo|fugit|officia|at|in|id|quos|reprehenderit|numquam|iste|fugiat|sit|inventore|beatae|repellendus|magnam|recusandae|quod|explicabo|doloremque|aperiam|consequatur|asperiores|commodi|optio|dolor|labore|temporibus|repellat|veniam|architecto|est|esse|mollitia|nulla|a|similique|eos|alias|dolore|tenetur|deleniti|porro|facere|maxime|corrupti)( (exercitationem|perferendis|perspiciatis|laborum|eveniet|sunt|iure|nam|nobis|eum|cum|officiis|excepturi|odio|consectetur|quasi|aut|quisquam|vel|eligendi|itaque|non|odit|tempore|quaerat|dignissimos|facilis|neque|nihil|expedita|vitae|vero|ipsum|nisi|animi|cumque|pariatur|velit|modi|natus|iusto|eaque|sequi|illo|sed|ex|et|voluptatibus|tempora|veritatis|ratione|assumenda|incidunt|nostrum|placeat|aliquid|fuga|provident|praesentium|rem|necessitatibus|suscipit|adipisci|quidem|possimus|voluptas|debitis|sint|accusantium|unde|sapiente|voluptate|qui|aspernatur|laudantium|soluta|amet|quo|aliquam|saepe|culpa|libero|ipsa|dicta|reiciendis|nesciunt|doloribus|autem|impedit|minima|maiores|repudiandae|ipsam|obcaecati|ullam|enim|totam|delectus|ducimus|quis|voluptates|dolores|molestiae|harum|dolorem|quia|voluptatem|molestias|magni|distinctio|omnis|illum|dolorum|voluptatum|ea|quas|quam|corporis|quae|blanditiis|atque|deserunt|laboriosam|earum|consequuntur|hic|cupiditate|quibusdam|accusamus|ut|rerum|error|minus|eius|ab|ad|nemo|fugit|officia|at|in|id|quos|reprehenderit|numquam|iste|fugiat|sit|inventore|beatae|repellendus|magnam|recusandae|quod|explicabo|doloremque|aperiam|consequatur|asperiores|commodi|optio|dolor|labore|temporibus|repellat|veniam|architecto|est|esse|mollitia|nulla|a|similique|eos|alias|dolore|tenetur|deleniti|porro|facere|maxime|corrupti)){2,12}){0,5}[.?] ){1,4}"
    in
    describe "Lorem ipsum"
        [ test re Nothing ]


test re info =
    case info of
        Nothing ->
            fuzz (fuzzRegex re) re <| check re

        Just str ->
            fuzz (fuzzRegex re) str <| check re


check : String -> String -> Expectation
check re str =
    case Regex.fromString re of
        Nothing ->
            Expect.fail ("not a valid regular expression (" ++ re ++ ")")

        Just regex ->
            if
                Regex.find regex str
                    |> List.map .match
                    |> List.head
                    |> Maybe.withDefault "2H7/s?.-+#Weflo230k"
                    |> (==) str
            then
                Expect.pass

            else
                Expect.fail ("regular expression (\"" ++ re ++ "\") did not match result => \"" ++ str ++ "\"")

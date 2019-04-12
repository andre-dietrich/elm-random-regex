# elm-random-regex

Turn regular expressions into random strings. Actually I did this, to use it for
fuzz testing, but it can also be used to generate any kind of nice random
values...


## Usage

This module exposes three functions and the type `Èncoding`, which is defined as
either an `ASCII` or `UNICODE`. All you actually need, is the function
`generate`, it receives the encoding type, a maximum infinity number and a
string, which defines your regular expression. To let your `*`, `+` and other
quantifiers, such as `{1,}` not to become too big, you have to define a maximum
value for infinity, in the code below, you will get strings with a max length of
200 characters.

``` elm
import Random.Regex exposing (Encoding(..))

...

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Generate ->
      case Random.Regex.generate ASCII 200 "a-z*" of
        Ok result ->
          ( model, Random.generate GenResult result )

        Err info ->
          ( { model | result = info }, Cmd.none )

    GenResult str ->
      ( { model | result = str }, Cmd.none )

    ...
```

The regular expression is parsed at first and since this parsing process might
fail, due to not correct definitions, you have to handle both cases. Either,
parsing went well and you will get a random generator, which does what you hope
;) or you get an error string. Unfortunatelly, I did not care so much on nice
error messages, so check your regex first.

You can also use the following two shortcuts:

``` elm
...
  -- equals Random.Regex.generate ASCII 250
  case Random.Regex.ascii "a-z*" of
    Ok result ->
      ( model, Random.generate GenResult result )

    Err info ->
      ( { model | result = info }, Cmd.none )

...
  -- equals Random.Regex.generate UNICODE 250
  case Random.Regex.unicode "#-ß*" of
    Ok result ->
      ( model, Random.generate GenResult result )

    Err info ->
      ( { model | result = info }, Cmd.none )
```

## Fuzz Testing

If you would like to use `Random.Regex` for fuzz-testing, you can use and modify
the following function. And use no shrinking, unfortunately, Shrink.string does
generate some empty strings, which can lead to false results.

``` elm
fuzzRegex : String -> Fuzzer String
fuzzRegex re =
  case Random.Regex.generate ASCII 199 re of
    Ok re ->
      Fuzz.custom re Shrink.noShrink

    Err info ->
      Fuzz.invalid ("not a valid regex (" ++ re ++ ") => " ++ info)
```

Have a look into the test-folder, to see some examples...

## Examples

Take a look at the following examples, to check out, what can be generated with
this package so far. This project contains also an `example/Main.elm` that can
be used for typing regular expressions and experimenting.

### Time

``` elm
Random.Regex.ascii "(1[0-2]|0[1-9])(:[0-5]\\d){2} (A|P)M"
```

__Results:__

``` text
06:01:34 AM
12:13:22 PM
11:54:26 PM
04:45:25 AM
10:02:30 PM
01:02:06 AM
11:41:23 AM
...
```

### Date

``` elm
Random.Regex.ascii "(January|February|March|April|May|June|July|August|September|October|November|December) ([1-9]|[12][0-9]|3[01]), (19|20)\\d\\d"
```

__Results:__

``` text
August 12, 1943
July 10, 1936
April 9, 2091
February 5, 2048
September 1, 2000
July 4, 2028
...
```

### SHA1 Hash

``` elm
Random.Regex.ascii "[a-f0-9]{40}"
```

__Results:__

``` text
1744620aca430ed0a084aa294b2651e7c78be09e
5ea36b5d7b87c2cca0121ce852f0cf9d50d155d6
4cb708394aab409dd4e49813ed95734d7e4ac22b
a25727ee31e91aebeffe0d29b11b8aafc8b2c92c
194b33fb34649941526fa45674e813def92006a6
b2644c90cb11bb22554a83d8e80430d68c55e052
ede961738f5fa50f1db0fe5d1a4faac6697af7c5
...
```

### Currency

``` elm
Random.Regex.ascii "\\$([1-9]{1,3}(,\\d{3}){0,3}|([1-9]{1,3}))(\\.\\d{2})?"
```

__Results:__

``` text
$357,595,758,499.02
$8,761,416.05
$243,789,586
$7
$191.23
$64,177.17
$1.47
...
```

### Lorem ipsum ...

See the result first, before you see the crazy Regex, no kind person should ever
be forced to write 8-)

``` text
Debitis perspiciatis  enim, obcaecati natus beatae  nobis
praesentium corporis asperiores sint vitae voluptas, sunt
harum sit enim mollitia laboriosam quod explicabo  minima
nulla eaque deleniti hic?  Deserunt quas nulla,  corporis
nobis  blanditiis  explicabo  amet  error  necessitatibus
earum,  cum qui repudiandae sunt  similique deserunt  sed
reprehenderit  sequi   eaque  commodi  corporis,  officia
repellendus quod,  magnam  ducimus  ad delectus  ratione,
nemo odio expedita soluta qui vel incidunt possimus neque
eos pariatur? Cumque ipsam eos ratione ipsam, perferendis
enim  cum  corrupti,  quia ducimus  aperiam  iste laborum
veritatis cupiditate exercitationem iusto veritatis natus
architecto  reiciendis,  necessitatibus odio  magnam eius
vel corporis  velit  atque?  Optio  quas  maxime  officia
deserunt soluta laboriosam quidem.
```


``` elm
let
  regex =
    "((Exercitationem|Perferendis|Perspiciatis|Laborum|"
    ++ "Eveniet|Sunt|Iure|Nam|Nobis|Eum|Cum|Officiis|Ex"
    ++ "cepturi|Odio|Consectetur|Quasi|Aut|Quisquam|Vel"
    ++ "|Eligendi|Itaque|Non|Odit|Tempore|Quaerat|Digni"
    ++ "ssimos|Facilis|Neque|Nihil|Expedita|Vitae|Vero|"
    ++ "Ipsum|Nisi|Animi|Cumque|Pariatur|Velit|Modi|Nat"
    ++ "us|Iusto|Eaque|Sequi|Illo|Sed|Ex|Et|Voluptatibu"
    ++ "s|Tempora|Veritatis|Ratione|Assumenda|Incidunt|"
    ++ "Nostrum|Placeat|Aliquid|Fuga|Provident|Praesent"
    ++ "ium|Rem|Necessitatibus|Suscipit|Adipisci|Quidem"
    ++ "|Possimus|Voluptas|Debitis|Sint|Accusantium|Und"
    ++ "e|Sapiente|Voluptate|Qui|Aspernatur|Laudantium|"
    ++ "Soluta|Amet|Quo|Aliquam|Saepe|Culpa|Libero|Ipsa"
    ++ "|Dicta|Reiciendis|Nesciunt|Doloribus|Autem|Impe"
    ++ "dit|Minima|Maiores|Repudiandae|Ipsam|Obcaecati|"
    ++ "Ullam|Enim|Totam|Delectus|Ducimus|Quis|Voluptat"
    ++ "es|Dolores|Molestiae|Harum|Dolorem|Quia|Volupta"
    ++ "tem|Molestias|Magni|Distinctio|Omnis|Illum|Dolo"
    ++ "rum|Voluptatum|Ea|Quas|Quam|Corporis|Quae|Bland"
    ++ "itiis|Atque|Deserunt|Laboriosam|Earum|Consequun"
    ++ "tur|Hic|Cupiditate|Quibusdam|Accusamus|Ut|Rerum"
    ++ "|Error|Minus|Eius|Ab|Ad|Nemo|Fugit|Officia|At|I"
    ++ "n|Id|Quos|Reprehenderit|Numquam|Iste|Fugiat|Sit"
    ++ "|Inventore|Beatae|Repellendus|Magnam|Recusandae"
    ++ "|Quod|Explicabo|Doloremque|Aperiam|Consequatur|"
    ++ "Asperiores|Commodi|Optio|Dolor|Labore|Temporibu"
    ++ "s|Repellat|Veniam|Architecto|Est|Esse|Mollitia|"
    ++ "Nulla|A|Similique|Eos|Alias|Dolore|Tenetur|Dele"
    ++ "niti|Porro|Facere|Maxime|Corrupti)( (exercitati"
    ++ "onem|perferendis|perspiciatis|laborum|eveniet|s"
    ++ "unt|iure|nam|nobis|eum|cum|officiis|excepturi|o"
    ++ "dio|consectetur|quasi|aut|quisquam|vel|eligendi"
    ++ "|itaque|non|odit|tempore|quaerat|dignissimos|fa"
    ++ "cilis|neque|nihil|expedita|vitae|vero|ipsum|nis"
    ++ "i|animi|cumque|pariatur|velit|modi|natus|iusto|"
    ++ "eaque|sequi|illo|sed|ex|et|voluptatibus|tempora"
    ++ "|veritatis|ratione|assumenda|incidunt|nostrum|p"
    ++ "laceat|aliquid|fuga|provident|praesentium|rem|n"
    ++ "ecessitatibus|suscipit|adipisci|quidem|possimus"
    ++ "|voluptas|debitis|sint|accusantium|unde|sapient"
    ++ "e|voluptate|qui|aspernatur|laudantium|soluta|am"
    ++ "et|quo|aliquam|saepe|culpa|libero|ipsa|dicta|re"
    ++ "iciendis|nesciunt|doloribus|autem|impedit|minim"
    ++ "a|maiores|repudiandae|ipsam|obcaecati|ullam|eni"
    ++ "m|totam|delectus|ducimus|quis|voluptates|dolore"
    ++ "s|molestiae|harum|dolorem|quia|voluptatem|moles"
    ++ "tias|magni|distinctio|omnis|illum|dolorum|volup"
    ++ "tatum|ea|quas|quam|corporis|quae|blanditiis|atq"
    ++ "ue|deserunt|laboriosam|earum|consequuntur|hic|c"
    ++ "upiditate|quibusdam|accusamus|ut|rerum|error|mi"
    ++ "nus|eius|ab|ad|nemo|fugit|officia|at|in|id|quos"
    ++ "|reprehenderit|numquam|iste|fugiat|sit|inventor"
    ++ "e|beatae|repellendus|magnam|recusandae|quod|exp"
    ++ "licabo|doloremque|aperiam|consequatur|asperiore"
    ++ "s|commodi|optio|dolor|labore|temporibus|repella"
    ++ "t|veniam|architecto|est|esse|mollitia|nulla|a|s"
    ++ "imilique|eos|alias|dolore|tenetur|deleniti|porr"
    ++ "o|facere|maxime|corrupti)){2,12}(, (exercitatio"
    ++ "nem|perferendis|perspiciatis|laborum|eveniet|su"
    ++ "nt|iure|nam|nobis|eum|cum|officiis|excepturi|od"
    ++ "io|consectetur|quasi|aut|quisquam|vel|eligendi|"
    ++ "itaque|non|odit|tempore|quaerat|dignissimos|fac"
    ++ "ilis|neque|nihil|expedita|vitae|vero|ipsum|nisi"
    ++ "|animi|cumque|pariatur|velit|modi|natus|iusto|e"
    ++ "aque|sequi|illo|sed|ex|et|voluptatibus|tempora|"
    ++ "veritatis|ratione|assumenda|incidunt|nostrum|pl"
    ++ "aceat|aliquid|fuga|provident|praesentium|rem|ne"
    ++ "cessitatibus|suscipit|adipisci|quidem|possimus|"
    ++ "voluptas|debitis|sint|accusantium|unde|sapiente"
    ++ "|voluptate|qui|aspernatur|laudantium|soluta|ame"
    ++ "t|quo|aliquam|saepe|culpa|libero|ipsa|dicta|rei"
    ++ "ciendis|nesciunt|doloribus|autem|impedit|minima"
    ++ "|maiores|repudiandae|ipsam|obcaecati|ullam|enim"
    ++ "|totam|delectus|ducimus|quis|voluptates|dolores"
    ++ "|molestiae|harum|dolorem|quia|voluptatem|molest"
    ++ "ias|magni|distinctio|omnis|illum|dolorum|volupt"
    ++ "atum|ea|quas|quam|corporis|quae|blanditiis|atqu"
    ++ "e|deserunt|laboriosam|earum|consequuntur|hic|cu"
    ++ "piditate|quibusdam|accusamus|ut|rerum|error|min"
    ++ "us|eius|ab|ad|nemo|fugit|officia|at|in|id|quos|"
    ++ "reprehenderit|numquam|iste|fugiat|sit|inventore"
    ++ "|beatae|repellendus|magnam|recusandae|quod|expl"
    ++ "icabo|doloremque|aperiam|consequatur|asperiores"
    ++ "|commodi|optio|dolor|labore|temporibus|repellat"
    ++ "|veniam|architecto|est|esse|mollitia|nulla|a|si"
    ++ "milique|eos|alias|dolore|tenetur|deleniti|porro"
    ++ "|facere|maxime|corrupti)( (exercitationem|perfe"
    ++ "rendis|perspiciatis|laborum|eveniet|sunt|iure|n"
    ++ "am|nobis|eum|cum|officiis|excepturi|odio|consec"
    ++ "tetur|quasi|aut|quisquam|vel|eligendi|itaque|no"
    ++ "n|odit|tempore|quaerat|dignissimos|facilis|nequ"
    ++ "e|nihil|expedita|vitae|vero|ipsum|nisi|animi|cu"
    ++ "mque|pariatur|velit|modi|natus|iusto|eaque|sequ"
    ++ "i|illo|sed|ex|et|voluptatibus|tempora|veritatis"
    ++ "|ratione|assumenda|incidunt|nostrum|placeat|ali"
    ++ "quid|fuga|provident|praesentium|rem|necessitati"
    ++ "bus|suscipit|adipisci|quidem|possimus|voluptas|"
    ++ "debitis|sint|accusantium|unde|sapiente|voluptat"
    ++ "e|qui|aspernatur|laudantium|soluta|amet|quo|ali"
    ++ "quam|saepe|culpa|libero|ipsa|dicta|reiciendis|n"
    ++ "esciunt|doloribus|autem|impedit|minima|maiores|"
    ++ "repudiandae|ipsam|obcaecati|ullam|enim|totam|de"
    ++ "lectus|ducimus|quis|voluptates|dolores|molestia"
    ++ "e|harum|dolorem|quia|voluptatem|molestias|magni"
    ++ "|distinctio|omnis|illum|dolorum|voluptatum|ea|q"
    ++ "uas|quam|corporis|quae|blanditiis|atque|deserun"
    ++ "t|laboriosam|earum|consequuntur|hic|cupiditate|"
    ++ "quibusdam|accusamus|ut|rerum|error|minus|eius|a"
    ++ "b|ad|nemo|fugit|officia|at|in|id|quos|reprehend"
    ++ "erit|numquam|iste|fugiat|sit|inventore|beatae|r"
    ++ "epellendus|magnam|recusandae|quod|explicabo|dol"
    ++ "oremque|aperiam|consequatur|asperiores|commodi|"
    ++ "optio|dolor|labore|temporibus|repellat|veniam|a"
    ++ "rchitecto|est|esse|mollitia|nulla|a|similique|e"
    ++ "os|alias|dolore|tenetur|deleniti|porro|facere|m"
    ++ "axime|corrupti)){2,12}){0,5}[.?] ){1,4}"
in
  Random.Regex.ascii regex
```

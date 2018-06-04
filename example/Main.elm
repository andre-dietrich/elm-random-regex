module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Random
import RegexGenerator exposing (..)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { pattern : String
    , result : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" "", Cmd.none )



-- UPDATE


type Msg
    = Update String
    | Roll
    | NewFace String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ->
            case RegexGenerator.regexGen model.pattern of
                Ok ( _, stream, result ) ->
                    ( model, Random.generate NewFace result )

                Err _ ->
                    ( { model | result = "ERROR" }, Cmd.none )

        NewFace newFace ->
            ( { model | result = newFace }, Cmd.none )

        Update str ->
            ( { model | pattern = str }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text (toString model.result) ]
        , textarea [ onInput Update ] [ text model.pattern ]
        , button [ onClick Roll ] [ text "Roll" ]
        ]

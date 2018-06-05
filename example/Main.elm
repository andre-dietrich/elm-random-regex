module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Random
import Random.Regex exposing (..)


main : Program Never Model Msg
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
            case Random.Regex.regex_ ASCII 20 model.pattern of
                Ok result ->
                    ( model, Random.generate NewFace result )

                Err msg ->
                    ( { model | result = msg }, Cmd.none )

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
        , input [ onInput Update ] [ text model.pattern ]
        , button [ onClick Roll ] [ text "Roll" ]
        ]

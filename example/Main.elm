module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Random
import Random.Regex exposing (..)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }



-- MODEL


type alias Model =
    { pattern : String
    , result : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" "", Cmd.none )



-- UPDATE


type Msg
    = Update String
    | Generate
    | GenResult String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Generate ->
            case Random.Regex.generate ASCII 200 model.pattern of
                Ok result ->
                    ( model, Random.generate GenResult result )

                Err info ->
                    ( { model | result = info }, Cmd.none )

        GenResult str ->
            ( { model | result = str }, Cmd.none )

        Update str ->
            ( { model | pattern = str }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ input [ onInput Update ] [ text model.pattern ]
        , button [ onClick Generate ] [ text "Generate" ]
        , br [] []
        , br [] []
        , pre [] [ code [] [ text model.result ] ]
        ]

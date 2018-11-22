port module Main exposing (main)

import Browser
import Html exposing (Html)


type alias Model =
    {}


type Msg
    = PortFunnelsMsg


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( {}
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Html.text "Shadow battle 5"


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

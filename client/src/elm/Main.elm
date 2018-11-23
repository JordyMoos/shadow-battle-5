port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Page.Home as Home
import Url exposing (Url)


type alias Model =
    { url : Url
    , key : Nav.Key
    , pageState : PageState
    }


type PageState
    = HomePage Home.Model


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | HomeMsg Home.Msg
    | NoOp


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( homeModel, homeCmd ) =
            Home.init
    in
    ( { url = url
      , key = key
      , pageState = HomePage homeModel
      }
    , Cmd.map HomeMsg homeCmd
    )


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest urlRequest =
    NoOp


onUrlChange : Url -> Msg
onUrlChange url =
    NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.pageState ) of
        ( HomeMsg pageMsg, HomePage pageModel ) ->
            ( model, Cmd.none )

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            ( { model
                | url = url
              }
            , Cmd.none
            )

        ( _, _ ) ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Shadow Battle"
    , body =
        [ case model.pageState of
            HomePage homeModel ->
                Home.view homeModel
                    |> Html.map HomeMsg
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

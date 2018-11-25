module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Json.Decode as Decode
import Page.Faq as Faq
import Page.Home as Home
import Page.User.Join as UserJoin
import Ports
import Route
import Url exposing (Url)


type alias Model =
    { url : Url
    , key : Nav.Key
    , pageState : PageState
    }


type PageState
    = HomePage Home.Model
    | FaqPage Faq.Model
    | UserJoinPage UserJoin.Model


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | HomeMsg Home.Msg
    | FaqMsg Faq.Msg
    | UserJoinMsg UserJoin.Msg
    | OnWebSocketMessage Decode.Value
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
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
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


changeRouteTo : Maybe Route.Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( model, Cmd.none )

        Just Route.Home ->
            let
                ( pageModel, pageCmd ) =
                    Home.init
            in
            ( { model | pageState = HomePage pageModel }
            , Cmd.map HomeMsg pageCmd
            )

        Just Route.Faq ->
            let
                ( pageModel, pageCmd ) =
                    Faq.init
            in
            ( { model | pageState = FaqPage pageModel }
            , Cmd.map FaqMsg pageCmd
            )

        Just Route.UserJoin ->
            let
                ( pageModel, pageCmd ) =
                    UserJoin.init
            in
            ( { model | pageState = UserJoinPage pageModel }
            , Cmd.map UserJoinMsg pageCmd
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.pageState ) of
        ( HomeMsg pageMsg, HomePage pageModel ) ->
            let
                ( newPageModel, newPageCmd ) =
                    Home.update pageMsg pageModel
            in
            ( { model | pageState = HomePage newPageModel }
            , Cmd.map HomeMsg newPageCmd
            )

        ( FaqMsg pageMsg, FaqPage pageModel ) ->
            let
                ( newPageModel, newPageCmd ) =
                    Faq.update pageMsg pageModel
            in
            ( { model | pageState = FaqPage newPageModel }
            , Cmd.map FaqMsg newPageCmd
            )

        ( UserJoinMsg pageMsg, UserJoinPage pageModel ) ->
            let
                ( newPageModel, newPageCmd ) =
                    UserJoin.update pageMsg pageModel
            in
            ( { model | pageState = UserJoinPage newPageModel }
            , Cmd.map UserJoinMsg newPageCmd
            )

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( _, _ ) ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Shadow Battle"
    , body =
        [ case model.pageState of
            HomePage pageModel ->
                Home.view pageModel
                    |> Html.map HomeMsg

            FaqPage pageModel ->
                Faq.view pageModel
                    |> Html.map FaqMsg

            UserJoinPage pageModel ->
                UserJoin.view pageModel
                    |> Html.map UserJoinMsg
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.receive OnWebSocketMessage

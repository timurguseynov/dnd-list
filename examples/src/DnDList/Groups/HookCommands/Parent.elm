module DnDList.Groups.HookCommands.Parent exposing
    ( Model
    , Msg
    , demoView
    , init
    , initialModel
    , subscriptions
    , update
    , url
    , view
    )

import DnDList.Groups.HookCommands.DetectDrop
import DnDList.Groups.HookCommands.DetectReorder
import Html
import Html.Attributes
import Html.Events



-- MODEL


type alias Model =
    { id : Int
    , examples : List Example
    }


type Example
    = DetectDrop DnDList.Groups.HookCommands.DetectDrop.Model
    | DetectReorder DnDList.Groups.HookCommands.DetectReorder.Model


initialModel : Model
initialModel =
    { id = 0
    , examples =
        [ DetectDrop DnDList.Groups.HookCommands.DetectDrop.initialModel
        , DetectReorder DnDList.Groups.HookCommands.DetectReorder.initialModel
        ]
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )


url : Int -> String
url id =
    case id of
        0 ->
            "https://raw.githubusercontent.com/annaghi/dnd-list/master/examples/src/DnDList.Groups/HookCommands/DetectDrop.elm"

        1 ->
            "https://raw.githubusercontent.com/annaghi/dnd-list/master/examples/src/DnDList.Groups/HookCommands/DetectReorder.elm"

        _ ->
            ""



-- UPDATE


type Msg
    = LinkClicked Int
    | DetectDropMsg DnDList.Groups.HookCommands.DetectDrop.Msg
    | DetectReorderMsg DnDList.Groups.HookCommands.DetectReorder.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LinkClicked id ->
            ( { model | id = id }, Cmd.none )

        _ ->
            model.examples
                |> List.map
                    (\example ->
                        case ( message, example ) of
                            ( DetectDropMsg msg, DetectDrop mo ) ->
                                stepDetectDrop (DnDList.Groups.HookCommands.DetectDrop.update msg mo)

                            ( DetectReorderMsg msg, DetectReorder mo ) ->
                                stepDetectReorder (DnDList.Groups.HookCommands.DetectReorder.update msg mo)

                            _ ->
                                ( example, Cmd.none )
                    )
                |> List.unzip
                |> (\( examples, cmds ) -> ( { model | examples = examples }, Cmd.batch cmds ))


stepDetectDrop : ( DnDList.Groups.HookCommands.DetectDrop.Model, Cmd DnDList.Groups.HookCommands.DetectDrop.Msg ) -> ( Example, Cmd Msg )
stepDetectDrop ( mo, cmds ) =
    ( DetectDrop mo, Cmd.map DetectDropMsg cmds )


stepDetectReorder : ( DnDList.Groups.HookCommands.DetectReorder.Model, Cmd DnDList.Groups.HookCommands.DetectReorder.Msg ) -> ( Example, Cmd Msg )
stepDetectReorder ( mo, cmds ) =
    ( DetectReorder mo, Cmd.map DetectReorderMsg cmds )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    model.examples
        |> List.map
            (\example ->
                case example of
                    DetectDrop mo ->
                        Sub.map DetectDropMsg (DnDList.Groups.HookCommands.DetectDrop.subscriptions mo)

                    DetectReorder mo ->
                        Sub.map DetectReorderMsg (DnDList.Groups.HookCommands.DetectReorder.subscriptions mo)
            )
        |> Sub.batch



-- VIEW


view : Model -> Html.Html Msg
view model =
    model.examples
        |> List.indexedMap (demoWrapperView model.id)
        |> Html.section []


demoWrapperView : Int -> Int -> Example -> Html.Html Msg
demoWrapperView currentId id example =
    Html.div
        [ Html.Attributes.style "display" "flex"
        , Html.Attributes.style "flex-wrap" "wrap"
        , Html.Attributes.style "justify-content" "center"
        , Html.Attributes.style "margin" "4em 0"
        ]
        [ demoView example
        , Html.div
            [ Html.Attributes.classList [ ( "link", True ), ( "is-active", id == currentId ) ]
            , Html.Events.onClick (LinkClicked id)
            ]
            [ Html.text (info example) ]
        ]


demoView : Example -> Html.Html Msg
demoView example =
    case example of
        DetectDrop mo ->
            Html.map DetectDropMsg (DnDList.Groups.HookCommands.DetectDrop.view mo)

        DetectReorder mo ->
            Html.map DetectReorderMsg (DnDList.Groups.HookCommands.DetectReorder.view mo)



-- EXAMPLE INFO


type alias Info =
    String


info : Example -> Info
info example =
    case example of
        DetectDrop _ ->
            "Detect drop with insert before"

        DetectReorder _ ->
            "Detect reorder with insert before"
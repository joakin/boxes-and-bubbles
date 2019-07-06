module Example exposing (main)

{-|


# Overview

A basic example of using BoxesAndBubbles.
The drawing is supplied by this module (the BoxesAndBubbles library provides only the model).
The scene is updated after each animation frame.


# Running

@docs main

-}

import BoxesAndBubbles as BB exposing (..)
import BoxesAndBubbles.Bodies exposing (..)
import BoxesAndBubbles.Math2D exposing (mul2)
import Browser exposing (element)
import Browser.Events exposing (onAnimationFrameDelta)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed as Keyed


inf =
    1 / 0



-- infinity, hell yeah


e0 =
    0.8



-- default restitution coefficient
-- box: (w,h) pos velocity density restitution
-- bubble: radius pos velocity density restitution


type alias Model meta =
    List (Body meta)


defaultLabel =
    ""


someBodies =
    [ bubble 30 1 e0 ( -80, 0 ) ( 1.5, 0 ) defaultLabel
    , bubble 70 inf 0 ( 80, 0 ) ( 0, 0 ) defaultLabel
    , bubble 40 1 e0 ( 0, 200 ) ( 0.4, -3.0 ) defaultLabel
    , bubble 80 0.1 e0 ( 300, -280 ) ( -2, 1 ) defaultLabel
    , bubble 15 5 0.4 ( 300, 300 ) ( -4, -3 ) defaultLabel
    , bubble 40 1 e0 ( 200, 200 ) ( -5, -1 ) defaultLabel
    , box ( 100, 100 ) 1 e0 ( 300, 0 ) ( 0, 0 ) defaultLabel
    , box ( 20, 20 ) 1 e0 ( -200, 0 ) ( 3, 0 ) defaultLabel
    , box ( 20, 40 ) 1 e0 ( 200, -200 ) ( -1, -1 ) defaultLabel
    ]
        ++ bounds ( 750, 750 ) 100 e0 ( 0, 0 ) defaultLabel



-- we'll just compute the label from the data in the body


bodyLabel restitution inverseMass =
    [ "e = "
    , String.fromFloat restitution
    , "\nm = "
    , String.fromInt (round (1 / inverseMass))
    ]
        |> String.concat


type alias Labeled =
    { label : String }


type alias LabeledBody =
    Body Labeled



--attachlabel label body =
--  let labelRecord = { label = label }
--  in { body }
-- and attach it to all the bodies


labeledBodies : Model String
labeledBodies =
    List.map (\b -> { b | meta = bodyLabel b.restitution b.inverseMass }) someBodies



-- why yes, it draws a body with label. Or creates the Element, rather


drawBody : Int -> Body String -> ( String, Html Msg )
drawBody i ({ pos, velocity, inverseMass, restitution, shape, meta } as b) =
    let
        info =
            span
                [ style "position" "absolute"
                , style "left" "0px"
                , style "top" "0px"
                , style "white-space" "nowrap"
                ]
                [ text meta ]

        rendered =
            case shape of
                Bubble radius ->
                    div
                        [ style "position" "absolute"
                        , style "left" <| (String.fromFloat <| Tuple.first pos - radius + 400) ++ "px"
                        , style "top" <| (String.fromFloat <| Tuple.second pos - radius + 400) ++ "px"
                        , style "width" <| String.fromFloat (radius * 2) ++ "px"
                        , style "height" <| String.fromFloat (radius * 2) ++ "px"
                        , style "border-radius" "100%"
                        , style "background-color" "lightgrey"
                        , style "border" "1px solid black"
                        ]
                        [ info ]

                Box extents ->
                    let
                        ( w, h ) =
                            extents
                    in
                    div
                        [ style "position" "absolute"
                        , style "left" <| (String.fromFloat <| Tuple.first pos - w + 400) ++ "px"
                        , style "top" <| (String.fromFloat <| Tuple.second pos - h + 400) ++ "px"
                        , style "width" <| String.fromFloat (w * 2) ++ "px"
                        , style "height" <| String.fromFloat (h * 2) ++ "px"
                        , style "background-color" "lightgrey"
                        , style "border" "1px solid black"
                        ]
                        [ info ]
    in
    ( String.fromInt i, rendered )


scene : Model String -> Html Msg
scene bodies =
    Keyed.node "div"
        [ style "width" <| String.fromFloat 800 ++ "px"
        , style "height" <| String.fromFloat 800 ++ "px"
        , style "position" "relative"
        ]
    <|
        List.indexedMap drawBody bodies



-- different force functions to experiment with
-- constant downward gravity


constgravity t =
    ( ( 0, 0.2 ), ( 0, 0 ) )



-- sinusoidal sideways force


sinforce t =
    ( (sin <| radians (t / 1000)) * 50, 0 )



-- small gravity, slowly accellerating upward drift


counterforces t =
    ( ( 0, -0.01 ), ( 0, t / 1000 ) )


type Msg
    = Tick Float


subs : Sub Msg
subs =
    onAnimationFrameDelta Tick


update : Msg -> Model meta -> Model meta
update (Tick dt) bodies =
    let
        ( gravity, ambient ) =
            constgravity dt
    in
    BB.step gravity ambient bodies


{-| Run the animation started from the initial scene defined as `labeledBodies`.
-}
main : Program () (Model String) Msg
main =
    element
        { init = \() -> ( labeledBodies, Cmd.none )
        , update = \msg bodies -> ( update msg bodies, Cmd.none )
        , subscriptions = always subs
        , view = scene
        }

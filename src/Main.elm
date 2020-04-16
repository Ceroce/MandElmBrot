module Main exposing (main)

import Browser
import Html exposing (Html, img)
import Html.Attributes exposing (src)
import Image exposing (Image)
import List

type alias Model = 
    { imageUrl: String
    }

type Msg = None

main = Browser.element 
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


-- INIT

init : () -> (Model, Cmd Msg)
init _ = 
    ( { imageUrl = defaultImage 300 200 |> Image.toPngUrl }
    , Cmd.none
    )

defaultImage : Int -> Int -> Image
defaultImage width height = 
    Image.fromList2d
        ( List.repeat height
            ( List.repeat width 0xFF0000FF )
        )

-- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    ( model
    , Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- VIEW

view : Model -> Html Msg 
view model = 
    img [ src model.imageUrl ] []
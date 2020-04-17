module Main exposing (main)

import Browser
import Html exposing (Html, img)
import Html.Attributes exposing (src)
import Image exposing (Image, Pixel)
import List

-- CONSTANTS

defaultCoordinates : SetCoordinates
defaultCoordinates = 
    { center = { x = -0.50, y = 0.0 }
    , spanX = 4.5
    , spanY = 3.0
    }

defaultImageSize : ImageSize
defaultImageSize = { width = 900, height = 600 }

-- Maximum number of iterations. Must be in the 1..255 range.
maxIter = 32

-- TYPES
type alias Model = 
    { imageUrl: String
    }

type Msg = None


-- MAIN

main = Browser.element 
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

-- INIT

init : () -> (Model, Cmd Msg)
init _ = 
    ( { imageUrl = (generateImage defaultImageSize defaultCoordinates) |> Image.toPngUrl }
    , Cmd.none
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


-- GENERATION

type alias Point = 
    { x: Float
    , y: Float
    }

type alias SetCoordinates =
    { center: Point
    , spanX: Float
    , spanY: Float
    }

type alias ImageSize =
    { width: Int
    , height: Int
    }

generateImage : ImageSize -> SetCoordinates -> Image
generateImage size coord =
    Image.fromList2d
        (List.range 0 (size.height-1) |> List.map (generateRowOfPixels size coord))

generateRowOfPixels : ImageSize -> SetCoordinates -> Int -> List Pixel
generateRowOfPixels imageSize coord y =
    List.range 0 (imageSize.width-1) |> List.map (generatePixel imageSize coord y)

generatePixel : ImageSize -> SetCoordinates -> Int -> Int -> Pixel
generatePixel imageSize coord y x =
    let point = pointForPixelCoord x y coord imageSize in
        colorForIteration (iterationsAtPoint point)

colorForIteration : Int -> Pixel
colorForIteration iter =
    let gray = floor(0xFF * (toFloat(iter)/toFloat(maxIter)))
    in
        gray*2^24 + gray*2^16 + gray*2^8 + 0xFF

pointForPixelCoord : Int -> Int -> SetCoordinates -> ImageSize -> Point
pointForPixelCoord pixelX pixelY coord size =
    let 
        xPixelRatio = toFloat(pixelX)/toFloat(size.width)
        yPixelRatio = toFloat(pixelY)/toFloat(size.height)
    in
        { x = coord.center.x - 0.5*coord.spanX + xPixelRatio*coord.spanX
        , y = coord.center.y - 0.5*coord.spanY + (1.0-yPixelRatio)*coord.spanY  
        } 


-- COMPLEX NUMBERS

type alias Complex = 
    { r: Float -- Real part
    , i: Float -- Imaginary part
    }

squared : Complex -> Complex
squared z =
    multiply z z

multiply : Complex -> Complex -> Complex
multiply z0 z1 =
    { r = z0.r * z1.r - z0.i * z1.i
    , i = z0.r * z1.i + z0.i * z1.r }

add : Complex -> Complex -> Complex
add z0 z1 =
    { r = z0.r + z1.r 
    , i = z0.i + z1.i
    }

squaredNorm : Complex -> Float
squaredNorm z =
    z.r * z.r + z.i * z.i

-- MANDELBROT SET

iterationsAtPoint : Point -> Int
iterationsAtPoint point =
    let 
        z0 = { r = 0.0, i = 0.0}
        c = {r = point.x, i = point.y} 
    in
        mandelbrot z0 c 0

mandelbrot : Complex -> Complex -> Int -> Int
mandelbrot z c iter =
    if iter == maxIter then iter else
        let 
            nextZ = squared z |> add c 
            sqNorm = squaredNorm nextZ
        in
            if sqNorm >= 4.0 then iter else (mandelbrot nextZ c (iter+1))

    
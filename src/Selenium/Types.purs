module Selenium.Types where

import Prelude
import Control.Monad.Eff (kind Effect)
import Control.Monad.Error.Class (throwError)
import Data.Foreign (F, Foreign, ForeignError(..), readString)
import Data.List.NonEmpty as NEL
import Data.Maybe (Maybe)
import Data.String (toLower)

foreign import data Builder ∷ Type
foreign import data SELENIUM ∷ Effect
foreign import data Driver ∷ Type
foreign import data Window ∷ Type
foreign import data Until ∷ Type
foreign import data Element ∷ Type
foreign import data Locator ∷ Type
foreign import data ActionSequence ∷ Type
foreign import data MouseButton ∷ Type
foreign import data ChromeOptions ∷ Type
foreign import data ControlFlow ∷ Type
foreign import data FirefoxOptions ∷ Type
foreign import data IEOptions ∷ Type
foreign import data LoggingPrefs ∷ Type
foreign import data OperaOptions ∷ Type
foreign import data ProxyConfig ∷ Type
foreign import data SafariOptions ∷ Type
foreign import data ScrollBehaviour ∷ Type
foreign import data FileDetector ∷ Type
foreign import data WindowHandle ∷ Type

-- | Copied from `purescript-affjax` because the only thing we
-- | need from `affjax` is `Method`
data Method
  = DELETE
  | GET
  | HEAD
  | OPTIONS
  | PATCH
  | POST
  | PUT
  | MOVE
  | COPY
  | CustomMethod String

derive instance eqMethod ∷ Eq Method

readMethod ∷ Foreign → F Method
readMethod f = do
  str ← readString f
  pure $ case toLower str of
    "delete" → DELETE
    "get" → GET
    "head" → HEAD
    "options" → OPTIONS
    "patch" → PATCH
    "post" → POST
    "put" → PUT
    "move" → MOVE
    "copy" → COPY
    a → CustomMethod a

data XHRState
  = Stale
  | Opened
  | Loaded

derive instance eqXHRState ∷ Eq XHRState

readXHRState ∷ Foreign → F XHRState
readXHRState f = do
  str ← readString f
  case str of
    "stale" → pure Stale
    "opened" → pure Opened
    "loaded" → pure Loaded
    _ → throwError $ NEL.singleton $ TypeMismatch "xhr state" "string"


type Location =
  { x ∷ Int
  , y ∷ Int
  }

type Size =
  { width ∷ Int
  , height ∷ Int
  }

newtype ControlKey = ControlKey String

type XHRStats =
  { method ∷ Method
  , url ∷ String
  , async ∷ Boolean
  , user ∷ Maybe String
  , password ∷ Maybe String
  , state ∷ XHRState
  }

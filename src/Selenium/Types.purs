module Selenium.Types where

import Prelude
import Data.Foreign.Class (IsForeign)
import Data.Foreign (readString, ForeignError(..))
import Data.String (toLower)
import Data.Either (Either(..))
import Data.Maybe (Maybe())

foreign import data Builder :: *
foreign import data SELENIUM :: !
foreign import data Driver :: *
foreign import data Until :: *
foreign import data Element :: *
foreign import data Locator :: *
foreign import data ActionSequence :: *
foreign import data MouseButton :: *
foreign import data ChromeOptions :: *
foreign import data ControlFlow :: *
foreign import data FirefoxOptions :: *
foreign import data IEOptions :: *
foreign import data LoggingPrefs :: *
foreign import data OperaOptions :: *
foreign import data ProxyConfig :: *
foreign import data SafariOptions :: *
foreign import data ScrollBehaviour :: *
foreign import data Capabilities :: *
foreign import data FileDetector :: *

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

instance eqMethod :: Eq Method where
  eq DELETE DELETE = true
  eq GET GET = true
  eq HEAD HEAD = true
  eq OPTIONS OPTIONS = true
  eq PATCH PATCH = true
  eq POST POST = true
  eq PUT PUT = true
  eq MOVE MOVE = true
  eq COPY COPY = true
  eq (CustomMethod a) (CustomMethod b) = a == b
  eq _ _ = false 
  

instance methodIsForeign :: IsForeign Method where
  read f = do
    str <- readString f
    pure $ case toLower str of
      "delete" -> DELETE
      "get" -> GET
      "head" -> HEAD
      "options" -> OPTIONS
      "patch" -> PATCH
      "post" -> POST
      "put" -> PUT
      "move" -> MOVE
      "copy" -> COPY
      a -> CustomMethod a 

data XHRState
  = Stale
  | Opened
  | Loaded

instance xhrStateEq :: Eq XHRState where
  eq Stale Stale = true
  eq Opened Opened = true
  eq Loaded Loaded = true
  eq _ _ = false

instance xhrStateIsForeign :: IsForeign XHRState where
  read f = do
    str <- readString f
    case str of
      "stale" -> pure Stale
      "opened" -> pure Opened
      "loaded" -> pure Loaded 
      _ -> Left $ TypeMismatch "xhr state" "string"

    

type Location =
  { x :: Number
  , y :: Number
  }

newtype ControlKey = ControlKey String


type XHRStats =
  { method :: Method 
  , url :: String
  , async :: Boolean
  , user :: Maybe String
  , password :: Maybe String
  , state :: XHRState
  } 

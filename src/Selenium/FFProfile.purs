module Selenium.FFProfile
       ( FFProfileBuild()
       , FFPreference()
       , buildFFProfile
       , setPreference
       , setStringPreference
       , setIntPreference
       , setNumberPreference
       , setBoolPreference
       , intToFFPreference
       , numberToFFPreference
       , stringToFFPreference
       , boolToFFPreference
       ) where

import Prelude
import Control.Monad.Aff (Aff())
import Selenium.Capabilities
import Selenium.Types
import Data.List (List(..), singleton)
import Data.Foldable (foldl)
import Data.Foreign (Foreign())
import Control.Monad.Writer (Writer(), execWriter)
import Control.Monad.Writer.Class (tell)
import Unsafe.Coerce (unsafeCoerce)

foreign import data FFProfile :: *
foreign import data FFPreference :: *

data Command
  = SetPreference String FFPreference

newtype FFProfileBuild a = FFProfileBuild (Writer (List Command) a)

unFFProfileBuild :: forall a. FFProfileBuild a -> Writer (List Command) a
unFFProfileBuild (FFProfileBuild a) = a

instance functorFFProfileBuild :: Functor FFProfileBuild where
  map f (FFProfileBuild a) = FFProfileBuild $ f <$> a

instance applyFFProfileBuild :: Apply FFProfileBuild where
  apply (FFProfileBuild f) (FFProfileBuild w) = FFProfileBuild $ f <*> w

instance bindFFProfileBuild :: Bind FFProfileBuild where
  bind (FFProfileBuild w) f = FFProfileBuild $ w >>= unFFProfileBuild <<< f

instance applicativeFFProfileBuild :: Applicative FFProfileBuild where
  pure = FFProfileBuild <<< pure

instance monadFFProfileBuild :: Monad FFProfileBuild

rule :: Command -> FFProfileBuild Unit
rule = FFProfileBuild <<< tell <<< singleton

setPreference :: String -> FFPreference -> FFProfileBuild Unit
setPreference key val = rule $ SetPreference key val

setStringPreference :: String -> String -> FFProfileBuild Unit
setStringPreference key = setPreference key <<< stringToFFPreference

setIntPreference :: String -> Int -> FFProfileBuild Unit
setIntPreference key = setPreference key <<< intToFFPreference

setNumberPreference :: String -> Number -> FFProfileBuild Unit
setNumberPreference key = setPreference key <<< numberToFFPreference

setBoolPreference :: String -> Boolean -> FFProfileBuild Unit
setBoolPreference key = setPreference key <<< boolToFFPreference

buildFFProfile :: forall e. FFProfileBuild Unit -> Aff (selenium :: SELENIUM|e) Capabilities
buildFFProfile commands = do
  profile <- interpret (execWriter $ unFFProfileBuild commands) <$> _newFFProfile
  _encode profile

interpret :: List Command -> FFProfile-> FFProfile
interpret commands b = foldl foldFn b commands
  where
  foldFn :: FFProfile -> Command -> FFProfile
  foldFn p (SetPreference k v) = _setFFPreference k v p


foreign import _setFFPreference :: forall e. String -> FFPreference -> FFProfile -> FFProfile
foreign import _newFFProfile :: forall e. Aff (selenium :: SELENIUM|e) FFProfile
foreign import _encode :: forall e. FFProfile -> Aff (selenium :: SELENIUM|e) Capabilities


intToFFPreference :: Int -> FFPreference
intToFFPreference = unsafeCoerce

numberToFFPreference :: Number -> FFPreference
numberToFFPreference = unsafeCoerce

stringToFFPreference :: String -> FFPreference
stringToFFPreference = unsafeCoerce

boolToFFPreference :: Boolean -> FFPreference
boolToFFPreference = unsafeCoerce

foreignToFFPreference :: Foreign -> FFPreference
foreignToFFPreference = unsafeCoerce

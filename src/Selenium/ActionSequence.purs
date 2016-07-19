-- | DSL for building action sequences
module Selenium.ActionSequence
       ( sequence
       , keyUp
       , keyDown
       , mouseToLocation
       , dndToElement
       , dndToLocation
       , sendKeys
       , mouseUp
       , mouseDown
       , hover
       , doubleClick
       , leftClick
       , click
       , Sequence()
       ) where

import Prelude
import Selenium.Types
import Selenium.MouseButton
import Data.List
import Data.Function.Uncurried
import Data.Foldable (foldl)
import Control.Monad.Writer (Writer(), execWriter)
import Control.Monad.Writer.Class (tell)
import Control.Monad.Aff (Aff())

data Command
  = Click MouseButton Element
  | DoubleClick MouseButton Element
  | KeyDown ControlKey
  | KeyUp ControlKey
  | MouseDown MouseButton Element
  | MouseToElement Element
  | MouseToLocation Location
  | MouseUp MouseButton Element
  | DnDToElement Element Element
  | DnDToLocation Element Location
  | SendKeys String

newtype Sequence a = Sequence (Writer (List Command) a)

unSequence :: forall a. Sequence a -> Writer (List Command) a
unSequence (Sequence a) = a

instance functorSequence :: Functor Sequence where
  map f (Sequence a) = Sequence $ f <$> a

instance applySequence :: Apply Sequence where
  apply (Sequence f) (Sequence w) = Sequence $ f <*> w

instance bindSequence :: Bind Sequence where
  bind (Sequence w) f = Sequence $ w >>= unSequence <<< f

instance applicativeSequence :: Applicative Sequence where
  pure = Sequence <<< pure

instance monadSequence :: Monad Sequence

rule :: Command -> Sequence Unit
rule = Sequence <<< tell <<< singleton


click :: MouseButton -> Element -> Sequence Unit
click btn el = rule $ Click btn el

leftClick :: Element -> Sequence Unit
leftClick = click leftButton

doubleClick :: MouseButton -> Element -> Sequence Unit
doubleClick btn el = rule $ DoubleClick btn el

hover :: Element -> Sequence Unit
hover el = rule $ MouseToElement el

mouseDown :: MouseButton -> Element -> Sequence Unit
mouseDown btn el = rule $ MouseDown btn el

mouseUp :: MouseButton -> Element -> Sequence Unit
mouseUp btn el = rule $ MouseUp btn el

sendKeys :: String -> Sequence Unit
sendKeys keys = rule $ SendKeys keys

mouseToLocation :: Location -> Sequence Unit
mouseToLocation loc = rule $ MouseToLocation loc

-- | This function is used only with special keys (META, CONTROL, etc)
-- | It doesn't emulate __keyDown__ event
keyDown :: ControlKey -> Sequence Unit
keyDown k = rule $ KeyDown k
-- | This function is used only with special keys (META, CONTROL, etc)
-- | It doesn't emulate __keyUp__ event
keyUp :: ControlKey -> Sequence Unit
keyUp k = rule $ KeyUp k

dndToElement :: Element -> Element -> Sequence Unit
dndToElement el tgt = rule $ DnDToElement el tgt

dndToLocation :: Element -> Location -> Sequence Unit
dndToLocation el tgt = rule $ DnDToLocation el tgt

sequence :: forall e. Driver -> Sequence Unit -> Aff (selenium :: SELENIUM|e) Unit
sequence driver commands = do
  seq <- newSequence driver
  performSequence $ interpret (execWriter $ unSequence commands) seq

interpret :: List Command -> ActionSequence -> ActionSequence
interpret commands seq =
  foldl foldFn seq commands
  where
  foldFn :: ActionSequence -> Command -> ActionSequence
  foldFn seq (Click btn el) = runFn3 _click seq btn el
  foldFn seq (DoubleClick btn el) = runFn3 _doubleClick seq btn el
  foldFn seq (MouseToElement el) = runFn2 _mouseToElement seq el
  foldFn seq (MouseToLocation loc) = runFn2 _mouseToLocation seq loc
  foldFn seq (MouseDown btn el) = runFn3 _mouseDown seq btn el
  foldFn seq (MouseUp btn el) = runFn3 _mouseUp seq btn el
  foldFn seq (KeyDown k) = runFn2 _keyDown seq k
  foldFn seq (KeyUp k) = runFn2 _keyUp seq k
  foldFn seq (SendKeys ks) = runFn2 _sendKeys seq ks
  foldFn seq (DnDToElement el tgt) = runFn3 _dndToElement seq el tgt
  foldFn seq (DnDToLocation el tgt) = runFn3 _dndToLocation seq el tgt


foreign import newSequence :: forall e. Driver -> Aff (selenium :: SELENIUM|e) ActionSequence

foreign import performSequence :: forall e. ActionSequence -> Aff (selenium :: SELENIUM |e) Unit

foreign import _click :: Fn3 ActionSequence MouseButton Element ActionSequence
foreign import _doubleClick :: Fn3 ActionSequence MouseButton Element ActionSequence
foreign import _mouseToElement :: Fn2 ActionSequence Element ActionSequence
foreign import _mouseToLocation :: Fn2 ActionSequence Location ActionSequence
foreign import _mouseDown :: Fn3 ActionSequence MouseButton Element ActionSequence
foreign import _mouseUp :: Fn3 ActionSequence MouseButton Element ActionSequence
foreign import _keyDown :: Fn2 ActionSequence ControlKey ActionSequence
foreign import _keyUp :: Fn2 ActionSequence ControlKey ActionSequence
foreign import _sendKeys :: Fn2 ActionSequence String ActionSequence
foreign import _dndToElement :: Fn3 ActionSequence Element Element ActionSequence
foreign import _dndToLocation :: Fn3 ActionSequence Element Location ActionSequence

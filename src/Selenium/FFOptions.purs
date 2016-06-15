module Selenium.FFOptions where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Writer (Writer, execWriter)
import Control.Monad.Writer.Class (tell)

import Data.List (List, singleton)
import Data.Foldable (foldl)

import Selenium.FFProfile as FFP
import Selenium.Capabilities (Capabilities)
import Selenium.Types (SELENIUM)

foreign import data FFOptions ∷ *

data Command
  = SetProfile (FFP.FFProfileBuild Unit)
  | SetCompiledProfile FFP.FFProfile
  | SetFFPath String
  | UseMarionette Boolean


newtype FFOptionsBuild a = FFOptionsBuild (Writer (List Command) a)
unFFOptionsBuild ∷ ∀ a. FFOptionsBuild a → Writer (List Command) a
unFFOptionsBuild (FFOptionsBuild a) = a

instance functorFFOptionsBuild ∷ Functor FFOptionsBuild where
  map f (FFOptionsBuild a) = FFOptionsBuild $ map f a

instance applyFFOptionsBuild ∷ Apply FFOptionsBuild where
  apply (FFOptionsBuild f) (FFOptionsBuild w) = FFOptionsBuild $ apply f w

instance bindFFOptionsBuild ∷ Bind FFOptionsBuild where
  bind (FFOptionsBuild w) f = FFOptionsBuild $ bind w (unFFOptionsBuild <<< f)

instance applicativeFFOptionsBuild ∷ Applicative FFOptionsBuild where
  pure = FFOptionsBuild <<< pure

instance monadFFOptionsBuild ∷ Monad FFOptionsBuild


rule ∷ Command → FFOptionsBuild Unit
rule = FFOptionsBuild <<< tell <<< singleton

setProfile ∷ FFP.FFProfileBuild Unit → FFOptionsBuild Unit
setProfile = rule <<< SetProfile

setCompiledProfile ∷ FFP.FFProfile → FFOptionsBuild Unit
setCompiledProfile = rule <<< SetCompiledProfile

setFFPath ∷ String → FFOptionsBuild Unit
setFFPath = rule <<< SetFFPath

useMarionette ∷ Boolean → FFOptionsBuild Unit
useMarionette = rule <<< UseMarionette

interpretFFOptions ∷ ∀ e. FFOptionsBuild Unit → Aff (selenium ∷ SELENIUM|e) FFOptions
interpretFFOptions build = do
  foldl mkAction _newFFOptions commands
  where
  commands ∷ List Command
  commands = execWriter $ unFFOptionsBuild build

  mkAction ∷ Aff (selenium ∷ SELENIUM|e) FFOptions → Command → Aff (selenium ∷ SELENIUM|e) FFOptions
  mkAction opts (SetFFPath str) = opts >>= _setBinary str
  mkAction opts (SetCompiledProfile ffP) = opts >>= _setProfile ffP
  mkAction opts (SetProfile ffPBuild) = do
    ffp ← FFP.interpretFFProfile ffPBuild
    opts >>= _setProfile ffp
  mkAction opts (UseMarionette use) = opts >>= _useMarionette use

foreign import _newFFOptions ∷ ∀ e. Aff (selenium ∷ SELENIUM|e) FFOptions
foreign import _setBinary ∷ ∀ e. String → FFOptions → Aff (selenium ∷ SELENIUM|e) FFOptions
foreign import _setProfile ∷ ∀ e. FFP.FFProfile → FFOptions → Aff (selenium ∷ SELENIUM|e) FFOptions
foreign import _useMarionette ∷ ∀ e. Boolean → FFOptions → Aff (selenium ∷ SELENIUM|e) FFOptions
foreign import toCapabilities ∷ ∀ e. FFOptions → Aff (selenium ∷ SELENIUM|e) Capabilities

--buildFFOptions ∷ ∀ e. FFOptionsBuild Unit → Aff (selenium ∷ SELENIUM|e) Capabilities
--buildFFOptions commands = do

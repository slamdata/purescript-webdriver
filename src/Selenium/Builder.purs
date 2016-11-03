module Selenium.Builder
  ( build
  , browser
  , version
  , platform
  , usingServer
  , scrollBehaviour
  , withCapabilities
  , Build
  ) where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Writer (Writer, execWriter)
import Control.Monad.Writer.Class (tell)

import Data.Foldable (foldl)
import Data.Function.Uncurried (Fn2, runFn2)
import Data.List (List(..), singleton)
import Data.Tuple (Tuple(..))

import Selenium.Browser (Browser, browserCapabilities, platformCapabilities, versionCapabilities)
import Selenium.Capabilities (Capabilities, emptyCapabilities)
import Selenium.Types (Builder, ScrollBehaviour, Driver, SELENIUM, SafariOptions, ProxyConfig, OperaOptions, LoggingPrefs, IEOptions, FirefoxOptions, ControlFlow, ChromeOptions)

data Command
  = SetChromeOptions ChromeOptions
  | SetControlFlow ControlFlow
  | SetEnableNativeEvents Boolean
  | SetFirefoxOptions FirefoxOptions
  | SetIeOptions IEOptions
  | SetLoggingPrefs LoggingPrefs
  | SetOperaOptions OperaOptions
  | SetProxy ProxyConfig
  | SetSafariOptions SafariOptions
  | SetScrollBehaviour ScrollBehaviour
  | UsingServer String

newtype Build a = Build (Writer (Tuple Capabilities (List Command)) a)

unBuild ∷ ∀ a. Build a → Writer (Tuple Capabilities (List Command)) a
unBuild (Build a) = a

instance functorBuild ∷ Functor Build where
  map f (Build a) = Build $ f <$> a

instance applyBuild ∷ Apply Build where
  apply (Build f) (Build w) = Build $ f <*> w

instance bindBuild ∷ Bind Build where
  bind (Build w) f = Build $ w >>= unBuild <<< f

instance applicativeBuild ∷ Applicative Build where
  pure = Build <<< pure

instance monadBuild ∷ Monad Build

rule ∷ Command → Build Unit
rule = Build <<< tell <<< Tuple emptyCapabilities <<< singleton

version ∷ String → Build Unit
version = withCapabilities <<< versionCapabilities

platform ∷ String → Build Unit
platform = withCapabilities <<< platformCapabilities

usingServer ∷ String → Build Unit
usingServer = rule <<< UsingServer

scrollBehaviour ∷ ScrollBehaviour → Build Unit
scrollBehaviour = rule <<< SetScrollBehaviour

withCapabilities ∷ Capabilities → Build Unit
withCapabilities c = Build $ tell $ Tuple c noRules
  where
  noRules ∷ List Command
  noRules = Nil

browser ∷ Browser → Build Unit
browser = withCapabilities <<< browserCapabilities

build ∷ ∀ e. Build Unit → Aff (selenium ∷ SELENIUM|e) Driver
build dsl = do
  builder ← _newBuilder
  case execWriter $ unBuild dsl of
    Tuple capabilities commands →
      _build $ runFn2 _withCapabilities (interpret commands builder) capabilities

interpret ∷ List Command → Builder → Builder
interpret commands b = foldl foldFn b commands
  where
  foldFn ∷ Builder → Command → Builder
  foldFn b (UsingServer s) = runFn2 _usingServer b s
  foldFn b (SetScrollBehaviour bh) = runFn2 _setScrollBehaviour b bh
  foldFn b _ = b


foreign import _newBuilder ∷ ∀ e. Aff (selenium ∷ SELENIUM|e) Builder
foreign import _build ∷ ∀ e. Builder → Aff (selenium ∷ SELENIUM|e) Driver

foreign import _usingServer ∷ Fn2 Builder String Builder
foreign import _setScrollBehaviour ∷ Fn2 Builder ScrollBehaviour Builder
foreign import _withCapabilities ∷ Fn2 Builder Capabilities Builder

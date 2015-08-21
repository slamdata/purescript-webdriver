module Selenium.Builder
       ( build
       , browser
       , forBrowser
       , usingServer
       , scrollBehaviour
       , withCapabilities
       , Build()
       ) where

import Prelude
import Selenium.Types
import Selenium.Browser
import Control.Monad.Eff
import Data.List
import Data.Function
import Data.Foldable (foldl)
import Control.Monad.Writer (Writer(), execWriter)
import Control.Monad.Writer.Class (tell)
import Control.Monad.Aff (Aff())

data Command
  = Browser String
  | ForBrowser String String String
  | SetChromeOptions ChromeOptions
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
  | WithCapabilities Capabilities

newtype Build a = Build (Writer (List Command) a)

unBuild :: forall a. Build a -> Writer (List Command) a
unBuild (Build a) = a

instance functorBuild :: Functor Build where
  map f (Build a) = Build $ f <$> a

instance applyBuild :: Apply Build where
  apply (Build f) (Build w) = Build $ f <*> w

instance bindBuild :: Bind Build where
  bind (Build w) f = Build $ w >>= unBuild <<< f

instance applicativeBuild :: Applicative Build where
  pure = Build <<< pure

instance monadBuild :: Monad Build

rule :: Command -> Build Unit
rule = Build <<< tell <<< singleton

browser :: Browser -> Build Unit
browser = rule <<< Browser <<< browser2str

forBrowser :: Browser -> String -> String -> Build Unit
forBrowser b v p = rule $ ForBrowser (browser2str b) v p

usingServer :: String -> Build Unit
usingServer = rule <<< UsingServer

scrollBehaviour :: ScrollBehaviour -> Build Unit
scrollBehaviour = rule <<< SetScrollBehaviour

withCapabilities :: Capabilities -> Build Unit
withCapabilities = rule <<< WithCapabilities

build :: forall e. Build Unit -> Aff (selenium :: SELENIUM|e) Driver
build commands = do
  builder <- _newBuilder
  _build $ interpret (execWriter $ unBuild commands) builder


interpret :: List Command -> Builder -> Builder
interpret commands b = foldl foldFn b commands
  where
  foldFn :: Builder -> Command -> Builder
  foldFn b (Browser br) = runFn2 _browser b br
  foldFn b (ForBrowser br v p) = runFn4 _forBrowser b br v p
  foldFn b (UsingServer s) = runFn2 _usingServer b s
  foldFn b (SetScrollBehaviour bh) = runFn2 _setScrollBehaviour b bh
  foldFn b (WithCapabilities c) = runFn2 _withCapabilities b c
  foldFn b _ = b


foreign import _newBuilder :: forall e. Aff (selenium :: SELENIUM|e) Builder
foreign import _build :: forall e. Builder -> Aff (selenium :: SELENIUM|e) Driver

foreign import _browser :: Fn2 Builder String Builder
foreign import _forBrowser :: Fn4 Builder String String String Builder
foreign import _usingServer :: Fn2 Builder String Builder
foreign import _setScrollBehaviour :: Fn2 Builder ScrollBehaviour Builder
foreign import _withCapabilities :: Fn2 Builder Capabilities Builder

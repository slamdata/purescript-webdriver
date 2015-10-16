module Selenium.Capabilities where

import Prelude
import Data.Monoid

foreign import data Capabilities :: *
foreign import emptyCapabilities :: Capabilities
foreign import appendCapabilities :: Capabilities -> Capabilities -> Capabilities

instance semigroupCapabilities :: Semigroup Capabilities where
  append = appendCapabilities

instance monoidCapabilities :: Monoid Capabilities where
  mempty = emptyCapabilities

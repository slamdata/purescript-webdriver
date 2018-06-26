module Selenium.Capabilities where

import Prelude

foreign import data Capabilities ∷ Type
foreign import emptyCapabilities ∷ Capabilities
foreign import appendCapabilities ∷ Capabilities → Capabilities → Capabilities

instance semigroupCapabilities ∷ Semigroup Capabilities where
  append = appendCapabilities

instance monoidCapabilities ∷ Monoid Capabilities where
  mempty = emptyCapabilities
